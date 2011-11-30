class CreateVideoThumbnails < ActiveRecord::Migration
  def change
    create_table "video_thumbnails" do |t|
      t.string   "thumbnail_file_name"
      t.string   "thumbnail_content_type"
      t.integer  "thumbnail_file_size"
      t.datetime "thumbnail_updated_at"
      t.integer  "video_id"
      t.timestamps
    end
  end
end
