class ChangeColumnToSalaryTemplates1 < ActiveRecord::Migration[5.0]
  def change

    remove_column :salary_templates, :basic_salary_unit, :string
    remove_column :salary_templates, :bonus_unit, :string
    remove_column :salary_templates, :attendance_award_unit, :string
    remove_column :salary_templates, :house_bonus_unit, :string
    remove_column :salary_templates, :total_count_unit, :string
    add_column :salary_templates, :region_bonus, :decimal, precision: 15, scale: 2
  end
end
