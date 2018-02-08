class RemoveColumnToPassTrials1 < ActiveRecord::Migration[5.0]
  def change
    remove_column :pass_trials, :creator_id, :integer
    add_column :pass_trials, :job_transfer_id, :integer
  end
end
