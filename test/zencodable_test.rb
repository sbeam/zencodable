require 'test_helper'

class ZencodableTest < ActiveSupport::TestCase

  test "updates job status when it needs to" do
    Zencodable::Encoder::Job.any_instance.stubs(:status => 'makin progress')
    vid = Factory :video, :zencoder_job_status => 'new'
    assert_equal 'makin progress', vid.job_status
  end

#context "The main module" do
#   should "respond to js_framework" do
#     Apotomo.js_framework = :jquery
#     assert_equal :jquery,  Apotomo.js_generator
#   end
# end


end
