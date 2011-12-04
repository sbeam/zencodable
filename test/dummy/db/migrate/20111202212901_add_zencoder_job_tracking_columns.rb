class AddZencoderJobTrackingColumns < ActiveRecord::Migration
  def change
    add_column :videos, :origin_url, :string
    add_column :videos, :zencoder_job_status, :string
    add_column :videos, :zencoder_job_created, :datetime
    add_column :videos, :zencoder_job_finished, :datetime
  end
end
