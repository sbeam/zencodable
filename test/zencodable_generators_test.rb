require 'test_helper'
require 'generators/zencodable/migration_generator'

class ZencodableGeneratorTest < Rails::Generators::TestCase
  destination Rails.root
  destination File.join(Rails.root, "tmp")
  tests ::Zencodable::Generators::Migration
  setup :prepare_destination

  test "creates a migration for the output files model" do
    run_generator %w(KittehMovie encoded_kitteh_vids)
    assert_migration "db/migrate/create_encoded_kitteh_vids.rb" do |migration|
      assert_match /create_table "encoded_kitteh_vids"/, migration
      assert_match /t\.integer\s+\"kitteh_movie_id\"/, migration
    end
    assert_migration "db/migrate/create_encoded_kitteh_vids_thumbnails.rb" do |migration|
      assert_match /create_table "encoded_kitteh_vid_thumbnails"/, migration
      assert_match /t\.integer\s+\"kitteh_movie_id\"/, migration
    end
  end

  test "creates a migration to add job tracking columns to the named model" do
    run_generator %w(KittehMovie encoded_kitteh_vids)
    assert_migration "db/migrate/add_zencoder_job_tracking_columns_to_kitteh_movies.rb" do |migration|
      assert_match /add_column :kitteh_movies, :origin_url, :string/, migration
      assert_match /add_column :kitteh_movies, :zencoder_job_status, :string/, migration
      assert_match /add_column :kitteh_movies, :zencoder_job_created, :datetime/, migration
      assert_match /add_column :kitteh_movies, :zencoder_job_finished, :datetime/, migration
    end
  end

  test "does not create a migration for the thumbnails when --skip_thumbnails is given" do
    run_generator %w(KittehMovie encoded_kitteh_vids --skip-thumbnails)
    assert_migration "db/migrate/create_encoded_kitteh_vids.rb"
    assert_no_migration "db/migrate/create_encoded_kitteh_vids_thumbnails.rb"
  end

end
