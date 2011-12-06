class ZencodableAddTrackingColumnsAndTables < ActiveRecord::Migration
  def change
    add_column :<%= name.tableize %>, :origin_url, :string
    add_column :<%= name.tableize %>, :zencoder_job_id, :string
    add_column :<%= name.tableize %>, :zencoder_job_status, :string
    add_column :<%= name.tableize %>, :zencoder_job_created, :datetime
    add_column :<%= name.tableize %>, :zencoder_job_finished, :datetime

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
      t.integer  "duration_sec"
      t.timestamps
    end

    <% if !options.skip_thumbnails %>
      create_table "<%= association_name.singularize %>_thumbnails" do |t|
        t.string   "thumbnail_file_name"
        t.string   "thumbnail_content_type"
        t.integer  "thumbnail_file_size"
        t.datetime "thumbnail_updated_at"
        t.integer  "<%= name.foreign_key %>"
        t.timestamps
      end
    <% end %>
  end
end
