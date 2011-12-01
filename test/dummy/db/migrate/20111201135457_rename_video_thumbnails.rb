class RenameVideoThumbnails < ActiveRecord::Migration
  def change
    rename_table :video_thumbnails, :video_file_thumbnails
  end
end
