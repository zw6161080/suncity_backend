class CreateSalaryValues < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_values do |t|
      t.decimal :decimal_value, precision: 15, scale: 2
      t.string :string_value
      t.integer :integer_value
      t.datetime :date_value
      t.integer :user_id
      t.jsonb :object_value
      t.integer :month_salary_report_id
      t.timestamps
    end
  end
end
