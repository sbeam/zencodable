FactoryGirl.define do
  factory :video do
    title "At the Foo Bar"
  end

  factory :video_file do
    format "ogg"
    zencoder_file_id 12345329
    duration_sec 120
    width 800
    height 600
    file_size 19293819
    state "finished"
    sequence(:url) { |n| "http://parallaxp.s3.amazonaws.com/videos/zc/video-title/file.#{n}.off" }
    video
  end
end
