class AddZencoderJobIdToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :zencoder_job_id, :string
  end
end
