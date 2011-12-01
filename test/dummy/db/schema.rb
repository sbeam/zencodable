# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111201135457) do

  create_table "video_file_thumbnails", :force => true do |t|
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.string   "origin_url"
    t.string   "zencoder_job_id"
    t.string   "zencoder_job_status"
    t.datetime "zencoder_job_created"
    t.datetime "zencoder_job_finished"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
