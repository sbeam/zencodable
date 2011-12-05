require 'rails/generators'
require 'rails/generators/named_base'

module Zencodable
  module Generators
    class Migration < ::Rails::Generators::NamedBase
      include Rails::Generators::Migration

      desc "creates migrations to create tables for the models that hold the encoded video files and thumbnails"

      argument :association_name, :type => :string, :default => 'video_files'
      class_option :skip_thumbnails, :type => :boolean, :default => false

      source_root File.expand_path("../templates", __FILE__)

      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          migration_number = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
          migration_number += 1
          migration_number.to_s
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

      def create_migration_files
        migration_template 'zencodable_add_tracking_columns_and_tables.rb', "db/migrate/zencodable_add_tracking_columns_and_tables"
      end

    end
  end
end

