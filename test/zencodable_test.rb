require 'test_helper'

class ZencodableTest < ActiveSupport::TestCase

  test "updates job status when it needs to" do
    Zencodable::Encoder::Job.any_instance.stubs(:status => 'makin progress')
    vid = Factory :video, :zencoder_job_status => 'new'
    assert_equal 'makin progress', vid.job_status
  end

  test "doesn't update job status when it doesn't need to" do
    Zencodable::Encoder::Job.any_instance.stubs(:status).returns('makin progress')
    vid = Factory :video, :zencoder_job_status => 'finished'
    assert_equal 'finished', vid.job_status
  end

  test "updates video files from the Job when job details are updated" do
    testurl = 'http://s3.com/6/7/8.flv'
    Zencodable::Encoder::Job.any_instance.stubs(:status => 'finished', :files => [{:url => testurl, :format => 'flv'}])
    vid = Factory :video, :zencoder_job_status => 'processing'

    assert_equal 'finished', vid.job_status
    assert_equal 1, vid.video_files.length
    assert_equal 'flv', vid.video_files.first.format
    assert_equal testurl, vid.video_files.first.url
  end

  test "updates video thumbnails from the Job" do
    testurl = 'http://s3.com/1/2/3.png'
    Zencodable::Encoder::Job.any_instance.stubs(:status => 'finished', :thumbnails => [{:thumbnail_file_name => testurl, :thumbnail_content_type => 'png'}])
    vid = Factory :video, :zencoder_job_status => 'processing'

    assert_equal 'finished', vid.job_status
    assert_equal 1, vid.video_thumbnails.length
    assert_equal testurl, vid.video_thumbnails.first.thumbnail_file_name
  end

  test "creates a new zencoder job when origin url is changed" do
    vid = Factory :video

    Zencodable::Encoder::Job.expects(:create).returns(Zencodable::Encoder::Job.new('123'))

    vid.origin_url = 'http://foo.com/1/2/4'
    vid.save

    assert_equal '123', vid.zencoder_job_id
    assert_equal 'new', vid.zencoder_job_status
  end

  test "has a method to get a specific file format" do
    vid = Factory :video
    file = Factory :video_file, :format => 'webm', :video => vid
    assert_equal file.url, vid.source_file_for('webm').url
  end

  test "creates a correct S3 url" do
    video_file = Factory :video, :origin_url => 'http://foo.com/somepath/2/4/Rainbows and puppies [HD].with unicorns.mov'
    assert_equal "s3://zenbucket.s3.amazonaws.com/videos/encoded/", Zencodable::Encoder::Job.s3_url(video_file, 'zenbucket')
  end

  test "builds the correct default settings" do
    video_file = Factory :video, :origin_url => 'http://foo.com/somepath/2/4/Rainbows and puppies [HD].with unicorns.mov'

    default_settings = [{
        :public => true,
        :format => "mp4",
        :label => "mp4",
        :mock => true,
        :filename => 'rainbows-and-puppies-hd.with-unicorns.mp4',
        :base_url => "s3://zenbucket.s3.amazonaws.com/videos/encoded/"
    }]

    Video.encoding_options = {:bucket => 'zenbucket', :path => 'videos/encoded'}

    assert_equal default_settings, Zencodable::Encoder::Job.build_encoder_output_options(video_file)
  end

  test "builds correct settings when a thumbnails are requested" do

    Video.encoding_options = {:formats => [:ogg, :mp4], :bucket => 'zenbucket', :path => 'videos/encoded', :thumbnails => { :number => 4 }}
    video_file = Factory :video, :origin_url => 'http://foo.com/somepath/2/4/super_tricks.mov'

    output_options = Zencodable::Encoder::Job.build_encoder_output_options(video_file)

    # there should be a thumbnails option set for the first format request
    assert_equal 4, output_options[0][:thumbnails][:number]

    # but not for any subsequent ones
    assert_nil output_options[1][:thumbnails]
  end

  test "interpolates model methods into the :path parameter" do
    Video.encoding_options = {:formats => [:ogg, :mp4],
                              :bucket => 'zenbucket',
                              :path => 'videos/encoded/:rating/:title'}
    Video.any_instance.stubs(:rating).returns('PG')
    video_file = Factory :video, :title => 'Last of the Mohecans', :origin_url => 'http://foo.com/somepath/super kittehs!.mov'

    output_options = Zencodable::Encoder::Job.build_encoder_output_options(video_file)

    assert_equal 's3://zenbucket.s3.amazonaws.com/videos/encoded/PG/Last of the Mohecans/', output_options[0][:base_url]

    assert_equal 'super-kittehs.ogg', output_options[0][:filename]
  end

end
