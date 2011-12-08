require 'zencoder'

module Zencodable
  extend ActiveSupport::Concern

  included do
    class_attribute :encoding_options
    class_attribute :encoder_output_files_association
    class_attribute :encoder_thumbnails_association
  end

  module ClassMethods

    def has_video_encodings target_association, options = {}
      self.encoding_options = options
      self.encoder_output_files_association = target_association

      has_many self.encoder_output_files_association, :dependent => :destroy

      unless options[:thumbnails].blank?
        self.encoder_thumbnails_association = "#{target_association.to_s.singularize}_thumbnails".to_sym
        has_many self.encoder_thumbnails_association, :dependent => :destroy
      end

      before_save :create_job

      # TODO cleanup
      #before_destroy :prepare_for_destroy
      #after_destroy :destroy_attached_files
    end

  end

  module InstanceMethods

    def job_status
      unless ['finished','failed'].include? zencoder_job_status
        logger.debug "Unfinished job found. Updating details."
        update_job
      end
      self.zencoder_job_status
    end

    def create_job
      if self.origin_url_changed?
        logger.debug "Origin URL changed. Creating new ZenCoder job."
        if @job = Encoder::Job.create(self)
          logger.debug "ZenCoder job created, ID = #{@job.id}"
          self.zencoder_job_id = @job.id
          self.zencoder_job_status = 'new'
          self.zencoder_job_created = Time.now
          self.zencoder_job_finished = nil
        end
      end
    end

    def update_job
      self.zencoder_job_status = encoder_job.status
      self.zencoder_job_finished = encoder_job.finished_at
      if encoded_files = encoder_job.files
        self.video_files = encoded_files.collect{ |file| video_files_class.new(file) }
      end
      if self.class.encoder_thumbnails_association && (encoded_thumbs = encoder_job.thumbnails)
        self.video_thumbnails = encoded_thumbs.collect{ |file| video_thumbnails_class.new(file) }
      end
      save
    end

    def source_file_for(fmt)
      self.video_files.where(:format => fmt).first
    end

    def video_files
      self.send(video_files_method)
    end

    def video_thumbnails
      self.send(video_files_thumbnails_method)
    end

    def video_files= *args
      self.send "#{video_files_method}=", *args
    end

    def video_thumbnails= *args
      self.send("#{video_files_thumbnails_method}=", *args) if video_files_thumbnails_method
    end


    private
    def encoder_job
      @job ||= Encoder::Job.new(self.zencoder_job_id)
    end

    def video_files_method
      self.class.encoder_output_files_association
    end

    def video_files_thumbnails_method
      self.class.encoder_thumbnails_association
    end

    # need to know the Class of the associations so we can instantiate some when job is complete.
    def video_files_class
      self.class.reflect_on_all_associations(:has_many).detect{ |reflection| reflection.name == self.class.encoder_output_files_association }.klass
    end

    def video_thumbnails_class
      self.class.reflect_on_all_associations(:has_many).detect{ |reflection| reflection.name == self.class.encoder_thumbnails_association }.klass
    end

  end



  module Encoder
    include Zencoder

    class Job < Zencoder::Job

      attr_accessor :id

      class << self

        attr_accessor :mock_all_requests

        def create origin_file
          response = super(:input => origin_file.origin_url,
                           :outputs => build_encoder_output_options(origin_file))
          if response.code == 201
            job_id = response.body['id']
            self.new(job_id)
          end
        end

        def build_encoder_output_options origin_file

          settings = origin_file.class.encoding_options

          formats = settings[:formats] || [:mp4]

          s3_base_url = s3_url(origin_file, (settings[:bucket] || s3_bucket_name(settings[:s3_config])))

          defaults = { :public => true, :mock => self.mock_request? }

          defaults[:size] = settings[:output_dimensions] if settings[:output_dimensions]

          defaults = defaults.merge(settings[:options]) if settings[:options]

          output_settings = formats.collect{ |f| defaults.merge( :format => f.to_s,
                                                                 :label => f.to_s,
                                                                 :filename => file_basename(origin_file.origin_url) + ".#{f}",
                                                                 :base_url => s3_base_url ) }

          if settings[:thumbnails]
            output_settings[0][:thumbnails] = {:base_url => s3_base_url}.merge(settings[:thumbnails])
          end
          output_settings

        end

        def s3_url origin_file, bucket
          path = origin_file.class.encoding_options[:path]
          path.scan(%r|:[a-z]\w+\b|) do |match|
            method = match.gsub(/^:/,'').to_sym
            path = path.gsub(/#{match}/, origin_file.send(method)) if origin_file.respond_to?(method)
          end
          "s3://#{bucket}.s3.amazonaws.com/#{path.gsub(%r#/\z#, '')}/"
        end

        def file_basename origin_url
          basename = origin_url.match( %r|([^/][^/\?]+)[^/]*\.[^.]+\z| )[1] # matches filename without extension
          basename.downcase.squish.gsub(/\s+/, '-').gsub(/[^\w\d_.-]/, '') # cheap/ugly to_url
        end

        def s3_bucket_name s3_config_file
          s3_config_file ||= "#{Rails.root}/config/s3.yml"
          @s3_config ||= YAML.load_file(s3_config_file)[Rails.env].symbolize_keys
          @s3_config[:bucket_name]
        end

        def mock_request?
          (Rails.env == 'test' || self.mock_all_requests)
        end

      end

      def initialize(job_id)
        @id = job_id
        @job_detail = {}
      end


      def details
        if @job_detail.empty? and @id
          response = self.class.details @id
          if response.code == 200
            @job_detail = response.body['job']
          end
        end
        @job_detail
      end

      def status
        self.details['state']
      end

      def finished_at
        self.details['finished_at']
      end

      def files
        if outfiles = self.details['output_media_files']
          outfiles.collect { |f| { :url =>              f['url'],
                                   :format =>           f['label'],
                                   :zencoder_file_id => f['id'],
                                   :created_at =>       f['finished_at'],
                                   :duration_sec =>     f['duration_in_ms'],
                                   :width =>            f['width'],
                                   :height =>           f['height'],
                                   :file_size =>        f['file_size_bytes'],
                                   :error_message =>    f['error_message'],
                                   :state =>            f['state'] }
                           }
        end
      end

      # ZC gives thumbnails for each output file format, but gives them the same
      # name and overwrites them at the same S3 location. So if we have f
      # formats, and ask for x thumbnails, we get x*f files described in the
      # details['thumbnails'] API, but there are actually only x on the S3
      # server.  So, the inject() here is done to pare that down to unique URLs,
      # and give us the cols/vals that paperclip in VideoThumbnail is going to want
      def thumbnails
        if thumbs = self.details['thumbnails']

          thumbs.inject([]) do |res,th|
            unless res.map{ |r| r[:thumbnail_file_name] }.include?(th['url'])
              res << { :thumbnail_file_name =>   th['url'],
                       :thumbnail_content_type =>th['format'],
                       :thumbnail_file_size =>   th['file_size_bytes'],
                       :thumbnail_updated_at =>  th['created_at']
                     }
            end
            res
          end

        end
      end

    end

  end
end


class ActiveRecord::Base
  include Zencodable
end

