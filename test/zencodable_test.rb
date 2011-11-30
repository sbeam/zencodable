require 'test_helper'

class ZencodableTest < ActiveSupport::TestCase

  test "updates job status when it needs to" do
    Zencodable::Encoder::Job.any_instance.stubs(:status => 'makin progress')
    vid = Video.new :zencoder_job_status => 'new'
    assert_equal 'makin progress', vid.job_status
  end

end
