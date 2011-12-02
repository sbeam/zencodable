class CreateDummyVideos < ActiveRecord::Migration
  def change
    create_table "videos", :force => true do |t|
      t.string   "title"
      t.timestamps
    end
  end
end
