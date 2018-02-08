class CreateSalaryTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_templates do |t|
      t.string :template_chinese_name
      t.string :template_english_name
      t.string :template_simple_chinese_name
      t.string :salary_unit
      t.integer :basic_salary
      t.integer :bonus
      t.integer :attendance_award
      t.integer :house_bonus
      t.integer :tea_bonus
      t.integer :kill_bonus
      t.integer :performance_bonus
      t.integer :charge_bonus
      t.integer :commission_bonus
      t.integer :receive_bonus
      t.integer :exchange_rate_bonus
      t.integer :guest_card_bonus
      t.integer :respect_bonus
      t.jsonb :belongs_to
      t.string :comment
      t.timestamps
    end
  end
end
