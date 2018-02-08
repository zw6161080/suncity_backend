class AddColumnsToSalaryTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_templates, :service_award, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :internship_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :performance_award, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :special_tie_bonus, :decimal, precision: 15, scale: 2
  end
end
