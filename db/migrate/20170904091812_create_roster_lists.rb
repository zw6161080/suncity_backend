class CreateRosterLists < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_lists do |t|
      t.string :region
      t.integer :status

      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name

      t.integer :location_id
      t.integer :department_id

      t.string :date_range
      t.date :start_date
      t.date :end_date

      t.integer :employment_counts
      t.integer :roster_counts
      t.integer :general_holiday_counts

      t.timestamps
    end
  end
end
