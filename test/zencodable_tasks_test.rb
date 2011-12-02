require "rails"
require "rails/test_help"
require 'rake'
require 'aws/s3'


class ZencodableTaskTest < ActiveSupport::TestCase
  test "it adds the correct bucket policy to the configured bucket" do
    @task_name = "app:options:refresh"

    YAML.expects(:load_file).with('/path/to/config/amazon_s3.yml').returns({"development" => { "access_key_id" => 'ABASBDSBA', 
                                                                                               "secret_access_key" => '99999999999', 
                                                                                               "bucket" => 'notabucket'}})
    AWS::S3::Base.expects(:establish_connection!).with(:access_key_id => 'ABASBDSBA', :secret_access_key => '99999999999')

    # now we could update the policy (not the ACL) if that was possible

    execute_rake('zencodable_tasks.rake', 'zencoder:add_s3_policy', '/path/to/config/amazon_s3.yml')
  end

  def execute_rake(file, task, *args)
    require 'rake'
    rake = Rake::Application.new
    Rake.application = rake
    Rake::Task.define_task(:environment)
    load File.expand_path("../../lib/tasks/zencodable_tasks.rake",  __FILE__)
    rake[task].invoke(*args)
  end

end

