require 'test_helper'
require 'generators/zencodable/migration_generator'

class ZencodableGeneratorTest < Rails::Generators::TestCase
  destination Rails.root
  destination File.join(Rails.root, "tmp")
  tests ::Zencodable::Generators::Migration
  setup :prepare_destination

  test "creates a migration for the output files model" do
    run_generator %w(KittehMovie encoded_kitteh_vids)
    assert_migration "db/migrate/zencodable_add_tracking_columns_and_tables.rb" do |migration|
      assert_match /create_table "encoded_kitteh_vids"/, migration
      assert_match /t\.integer\s+\"kitteh_movie_id\"/, migration

      assert_match /create_table "encoded_kitteh_vid_thumbnails"/, migration
      assert_match /t\.integer\s+\"kitteh_movie_id\"/, migration

      assert_match /add_column :kitteh_movies, :origin_url, :string/, migration
      assert_match /add_column :kitteh_movies, :zencoder_job_status, :string/, migration
      assert_match /add_column :kitteh_movies, :zencoder_job_created, :datetime/, migration
      assert_match /add_column :kitteh_movies, :zencoder_job_finished, :datetime/, migration
    end
  end

  test "does not create a migration for the thumbnails when --skip_thumbnails is given" do
    run_generator %w(KittehMovie encoded_kitteh_vids --skip-thumbnails)
    assert_migration "db/migrate/zencodable_add_tracking_columns_and_tables.rb" do |migration|
      assert_no_match /create_table "encoded_kitteh_vid_thumbnails"/, migration
    end
  end

end
