class AddSalaryTemplateIdToPassTrial < ActiveRecord::Migration[5.0]
  def change
    add_column :pass_trials, :salary_template_id, :integer
  end
end
