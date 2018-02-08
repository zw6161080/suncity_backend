class RemoveJobTransferIdToJobTransfers < ActiveRecord::Migration[5.0]
  def change
    remove_column :pass_trials, :job_transfer_id, :integer
    remove_column :pass_entry_trials, :job_transfer_id, :integer
    remove_column :special_assessments, :job_transfer_id, :integer
    remove_column :transfer_position_apply_by_employees, :job_transfer_id, :integer
    remove_column :transfer_position_apply_by_departments, :job_transfer_id, :integer
    remove_column :transfer_location_applies, :job_transfer_id, :integer
    remove_column :lent_temporarily_applies, :job_transfer_id, :integer
  end
end
