class CreateDummyVideos < ActiveRecord::Migration
  def change
    create_table "videos", :force => true do |t|
      t.string   "title"
      t.string   "origin_url"
      t.string   "zencoder_job_id"
      t.string   "zencoder_job_status"
      t.datetime "zencoder_job_created"
      t.datetime "zencoder_job_finished"
      t.timestamps
    end
  end
end
