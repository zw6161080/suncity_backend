class CreateWelfareTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :welfare_templates do |t|
      t.string :template_chinese_name, null: false
      t.string :template_english_name, null: false
      t.integer :annual_leave, null: false
      t.integer :sick_leave, null: false
      t.integer :office_holiday, null: false
      t.integer :holiday_type ,null: false
      t.integer :probation, null: false
      t.integer :notice_period, null: false
      t.boolean :variant, null: false
      t.boolean :reduce_salary_for_leave, null: false
      t.boolean :provide_airfare, null: false
      t.boolean :provide_accommodation, null: false
      t.boolean :provide_uniform, null: false
      t.boolean :salary_composition, null: false
      t.integer :over_time_salary, null: false
      t.string :comment
      t.timestamps
    end
  end
end
