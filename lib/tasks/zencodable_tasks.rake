require 'aws/s3'

namespace :zencoder do
  desc "adds a policy to your S3 bucket that should allow Zencoder to place its output files there"
  task :add_s3_policy, :s3_config_file do |t, args|
    s3_config_file = args[:s3_config_file] || "#{Rails.root}/config/s3.yml"
    s3_config = YAML.load_file(s3_config_file)[Rails.env].symbolize_keys

    AWS::S3::Base.establish_connection!(
      :access_key_id     => s3_config[:access_key_id],
      :secret_access_key => s3_config[:secret_access_key]
    )
    bucket = s3_config[:bucket]
    # now if only we could update the policy (not the ACL) here, this might work
    # AWS::S3::Bucket.find(bucket).acl.grants << somegrant
  end
end
