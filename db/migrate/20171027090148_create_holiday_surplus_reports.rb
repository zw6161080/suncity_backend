class CreateHolidaySurplusReports < ActiveRecord::Migration[5.0]
  def change
    create_table :holiday_surplus_reports do |t|
      t.integer :user_id

      t.integer :last_year_surplus
      t.integer :total
      t.integer :used
      t.integer :surplus

      t.timestamps
    end
  end
end
