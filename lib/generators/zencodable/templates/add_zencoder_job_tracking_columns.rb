class AddZencoderJobTrackingColumns < ActiveRecord::Migration
  def change
    add_column :<%= name.tableize %>, :origin_url, :string
    add_column :<%= name.tableize %>, :zencoder_job_status, :string
    add_column :<%= name.tableize %>, :zencoder_job_created, :datetime
    add_column :<%= name.tableize %>, :zencoder_job_finished, :datetime
  end
end
