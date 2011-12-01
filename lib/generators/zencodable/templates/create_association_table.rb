class CreateZencodableOutputFilesAssociationTable < ActiveRecord::Migration
  def change
    create_table "<%= association_name %>" do |t|
      t.string   "url"
      t.string   "format"
      t.integer  "zencoder_file_id"
      t.integer  "<%= name.foreign_key %>"
      t.datetime "created_at"
      t.integer  "width"
      t.integer  "height"
      t.integer  "file_size"
      t.string   "error_message"
      t.string   "state"
      t.timestamps
    end
  end
end
