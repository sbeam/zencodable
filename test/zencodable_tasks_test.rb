require "rails"
require "rails/test_help"
require 'rake'
load File.expand_path("../../lib/tasks/zencodable_tasks.rake",  __FILE__)


class ZencodableTaskTest < ActiveSupport::TestCase
  test "it adds the correct bucket policy to the configured bucket" do
  end
end

