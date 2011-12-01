require 'rails/generators'
require 'rails/generators/named_base'

module Zencodable
  module Generators
    class ZencodableGenerator < ::Rails::Generators::NamedBase
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
        migration_template 'create_association_table.rb', "db/migrate/create_#{association_name}"
        unless options.skip_thumbnails?
          migration_template 'create_association_thumbnails_table.rb', "db/migrate/create_#{association_name}_thumbnails"
        end
      end

    end
  end
end

