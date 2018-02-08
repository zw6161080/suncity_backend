class AddSalaryTemplateToPassEntryTrial < ActiveRecord::Migration[5.0]
  def change
    add_column :pass_entry_trials, :salary_template, :jsonb
    add_column :pass_entry_trials, :new_salary_template, :jsonb
    remove_column :pass_entry_trials, :salary_template_id, :integer
  end
end
