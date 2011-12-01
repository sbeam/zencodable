require 'zencoder'

module Zencodable
  extend ActiveSupport::Concern

  included do
    #logger.warn "Bytes move down a wire. The codec is available. A video plays."
    class_attribute :encoder_definitions
    class_attribute :encoder_target_association
    class_attribute :encoder_thumbnails_association
  end

  module ClassMethods

    def has_video_encodings target_association, options = {}
      self.encoder_definitions = options
      self.encoder_target_association = target_association

      has_many self.encoder_target_association, :dependent => :destroy

      unless options[:thumbnails].blank?
        self.encoder_thumbnails_association = "#{target_association.to_s.singularize}_thumbnails".to_sym
        has_many self.encoder_thumbnails_association, :dependent => :destroy
      end

      before_save :create_job

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
        if @job = Encoder::Job.create(origin_url, self.class.encoder_definitions)
          zencoder_job_id = @job.id
          zencoder_job_status = 'new'
          zencoder_job_created = Time.now
          zencoder_job_finished = nil
        end
      end
    end

    def update_job
      self.zencoder_job_status = encoder_job.status
      self.zencoder_job_finished = encoder_job.finished_at
      video_files = encoder_job.files.collect{ |file| video_files_class.new(file) } rescue []
      video_thumbnails = encoder_job.thumbnails.collect{ |file| video_thumbnails_class.new(file) } rescue []
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
      self.send("#{video_files_thumbnails_method}=", *args) if self.respond_to?(video_files_thumbnails_method)
    end


    private
    def encoder_job
      @job ||= Encoder::Job.new(self.zencoder_job_id)
    end

    def video_files_method
      self.class.encoder_target_association
    end

    def video_files_thumbnails_method
      self.class.encoder_thumbnails_association
    end

    def video_files_class
      self.class.reflect_on_all_associations(:has_many).detect{ |reflection| reflection.name == self.class.encoder_target_association }.klass
    end

    def video_thumbnails_class
      self.class.reflect_on_all_associations(:has_many).detect{ |reflection| reflection.name == self.class.encoder_thumbnails_association }.klass
    end

  end



  module Encoder
    include Zencoder

    class Job < Zencoder::Job

      def self.config
        @@config ||= YAML.load_file("#{Rails.root}/config/amazon_s3.yml")[Rails.env].symbolize_keys
      end

      def self.create(origin, encoder_definitions)
        response = super(:input => origin,
                         :outputs => build_encoder_output_options(origin, encoder_definitions))
        if response.code == 201
          id = response.body['id']
          logger.debug "ZenCoder job ID = #{id}"
          self.new(id)
        end
      end

      attr_accessor :id

      def initialize(id)
        @id = id
        @job_detail = {}
      end

      def self.s3_url definitions
          path = definitions[:path] # TODO interpolate like paperclip?
          "s3://#{config[:bucket_name]}.s3.amazonaws.com/#{path}"
      end

      def self.build_encoder_output_options(origin, definitions)

        formats = definitions[:formats] || [:ogg]
        size = definitions[:output_dimensions] || '400x300'

        defaults = { :public => true,
                     :device_profile => "mobile/advanced",
                     :size => size
                   }
        defaults = defaults.merge(definitions[:options]) if definitions[:options]

        if definitions[:thumbnails]
          defaults[:thumbnails] = {:aspect_mode => 'crop',
                                   :base_url => s3_url(definitions),
                                   :size => size
                                  }.merge(definitions[:thumbnails])
        end

        # basename = origin.match( %r|([^/][^/\?.]+)[^/]*\z| )[1] # matches filename without extension
        formats.collect{ |f| defaults.merge( :format => f.to_s, :label => f.to_s, :base_url => s3_url ) }
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

