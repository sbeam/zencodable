class Video < ActiveRecord::Base

  has_video_encodings :video_files, :formats            => [:ogg, :mp4, :webm, :flv],
                                    :output_dimensions  => '852x480',
                                    :s3_config          => "#{Rails.root}/config/amazon_s3.yml",
                                    :path               => "videos/zc/:id/",
                                    :thumbnails         => { :number => 4, :aspect_mode => 'crop', 'size' => '290x160' },
                                    :options            => { :device_profile => 'mobile/advanced' }

end
