class CreateVideoFiles < ActiveRecord::Migration
  def change
    create_table "video_files", :force => true do |t|
      t.string   "url"
      t.string   "format"
      t.integer  "zencoder_file_id"
      t.integer  "video_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "duration_sec"
      t.integer  "width"
      t.integer  "height"
      t.integer  "file_size"
      t.string   "error_message"
      t.string   "state"
    end
  end
end
