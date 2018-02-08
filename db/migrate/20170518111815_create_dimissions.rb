class CreateDimissions < ActiveRecord::Migration[5.0]
  def change
    create_table :dimissions do |t|
      t.references :user, foreign_key: true
      t.date :apply_date
      t.date :inform_date
      t.date :last_work_date
      t.boolean :is_in_blacklist
      t.text :comment
      t.date :last_salary_begin_date
      t.date :last_salary_end_date
      t.integer :remaining_annual_holidays
      t.jsonb :follow_ups
      t.text :apply_comment
      t.jsonb :resignation_reason
      t.string :resignation_reason_extra
      t.jsonb :resignation_future_plan
      t.string :resignation_future_plan_extra
      t.string :resignation_certificate_language
      t.boolean :resignation_is_inform_period_exempted
      t.integer :resignation_inform_period_penalty
      t.boolean :resignation_is_recommanded_to_other_department
      t.jsonb :termination_reason
      t.string :termination_reason_extra
      t.integer :termination_inform_peroid_days
      t.boolean :termination_is_reasonable
      t.string :termination_compensation_extra

      t.timestamps
    end
  end
end
