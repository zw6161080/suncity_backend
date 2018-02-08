class ChangeColumnsToPassEntryTrails < ActiveRecord::Migration[5.0]
  def change
    remove_column :pass_entry_trials, :creator_id, :integer
    add_column :pass_entry_trials, :job_transfer_id, :integer
    rename_column :pass_entry_trials, :salary_template, :salary_record
    rename_column :pass_entry_trials, :new_salary_template, :new_salary_record
  end
end
