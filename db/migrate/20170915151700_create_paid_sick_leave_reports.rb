class CreatePaidSickLeaveReports < ActiveRecord::Migration[5.0]
  def change
    create_table :paid_sick_leave_reports do |t|
      t.integer :year
      t.date :valid_period
      t.boolean :is_release
      t.timestamps
    end
  end
end
