class ChangeColumnToSalaryTemplates < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_templates, :salary_unit, :string
    add_column :salary_templates, :basic_salary_unit, :string
    add_column :salary_templates, :bonus_unit, :string
    add_column :salary_templates, :attendance_award_unit, :string
    add_column :salary_templates, :house_bonus_unit, :string
    add_column :salary_templates, :total_count_unit, :string

    #new_year_bonus 新春利是分数
    add_column :salary_templates, :new_year_bonus, :decimal, precision: 15, scale: 2
    #project_bonus 项目分红分数
    add_column :salary_templates, :project_bonus, :decimal, precision: 15, scale: 2
    #product_bonus 尚频奖金分数
    add_column :salary_templates, :product_bonus, :decimal, precision: 15, scale: 2

    remove_column :salary_templates, :tea_bonus, :integer
    remove_column :salary_templates, :kill_bonus, :integer
    remove_column :salary_templates, :performance_bonus, :integer
    remove_column :salary_templates, :charge_bonus, :integer
    remove_column :salary_templates, :commission_bonus, :integer
    remove_column :salary_templates, :receive_bonus, :integer
    remove_column :salary_templates, :exchange_rate_bonus, :integer
    remove_column :salary_templates, :guest_card_bonus, :integer
    remove_column :salary_templates, :respect_bonus, :integer

    add_column :salary_templates, :tea_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :kill_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :performance_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :charge_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :commission_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :receive_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :exchange_rate_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :guest_card_bonus, :decimal, precision: 15, scale: 2
    add_column :salary_templates, :respect_bonus, :decimal, precision: 15, scale: 2

  end
end
