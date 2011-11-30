# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
plugin_test_dir = File.dirname(__FILE__)

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'logger'
require 'factory_girl'

require 'factories'

Rails.backtrace_cleaner.remove_silencers!

ActiveRecord::Base.logger = Logger.new(plugin_test_dir + "/debug.log")

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
