class RemoveColumnToPassTrials < ActiveRecord::Migration[5.0]
  def change
    rename_column :pass_trials, :salary_template, :salary_record
    rename_column :pass_trials, :new_salary_template, :new_salary_record

  end
end
