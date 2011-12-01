class CreateZencodableOutputFilesAssociationTable < ActiveRecord::Migration
  def change
    create_table "<%= association_name.singularize %>_thumbnails" do |t|
      t.string   "thumbnail_file_name"
      t.string   "thumbnail_content_type"
      t.integer  "thumbnail_file_size"
      t.datetime "thumbnail_updated_at"
      t.integer  "<%= name.foreign_key %>"
      t.timestamps
    end
  end
end
