class CreateAdjustRosterReports < ActiveRecord::Migration[5.0]
  def change
    create_table :adjust_roster_reports do |t|
      t.integer :user_id

      t.integer :not_special
      t.integer :not_special_for_class
      t.integer :not_special_for_holiday

      t.integer :special
      t.integer :special_for_class
      t.integer :special_for_holiday

      t.timestamps
    end
  end
end
