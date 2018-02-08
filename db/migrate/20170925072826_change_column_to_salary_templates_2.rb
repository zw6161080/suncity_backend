class ChangeColumnToSalaryTemplates2 < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_templates, :basic_salary, :integer
    remove_column :salary_templates, :bonus, :integer
    remove_column :salary_templates, :attendance_award, :integer
    remove_column :salary_templates, :house_bonus, :integer

    add_column :salary_templates, :basic_salary, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :bonus, :decimal,  precision: 15, scale: 2
    add_column :salary_templates, :attendance_award, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :house_bonus, :decimal, precision: 15, scale: 2


  end
end
