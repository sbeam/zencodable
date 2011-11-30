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
    testurl = 'http://s3.com/1/2/3.flv'
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
    Zencodable::Encoder::Job.stubs(:create).returns(Zencodable::Encoder::Job.new('123'))

    vid = Factory :video
    vid.origin_url = 'http://foo.com/1/2/4'
    assert vid.origin_url_changed?

    vid.save
    assert_not_nil vid.zencoder_job_id
    assert_equal 'new', vid.zencoder_job_status
  end

  test "has a method to get a specific file format" do
    vid = Factory :video
    file = Factory :video_file, :format => 'webm', :video => vid
    assert_equal file.url, vid.source_file_for('webm').url
  end



#context "The main module" do
#   should "respond to js_framework" do
#     Apotomo.js_framework = :jquery
#     assert_equal :jquery,  Apotomo.js_generator
#   end
# end


end
