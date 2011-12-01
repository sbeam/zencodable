require 'test_helper'
require 'generators/zencodable/zencodable_generator'

class ZencodableGeneratorTest < Rails::Generators::TestCase
  destination Rails.root
  destination File.join(Rails.root, "tmp")
  tests ::Zencodable::Generators::Migrate
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

  test "does not create a migration for the thumbnails when --skip_thumbnails is given" do
    run_generator %w(KittehMovie encoded_kitteh_vids --skip-thumbnails)
    assert_migration "db/migrate/create_encoded_kitteh_vids.rb"
    assert_no_migration "db/migrate/create_encoded_kitteh_vids_thumbnails.rb"
  end

end
