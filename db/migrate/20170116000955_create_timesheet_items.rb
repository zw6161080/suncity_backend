class CreateTimesheetItems < ActiveRecord::Migration[5.0]
  def change
    create_table :timesheet_items do |t|
      t.belongs_to :timesheet
      t.string :uid
      t.date :date
      t.timestamp :clock_in
      t.timestamp :clock_off
      t.string :init_state
      t.timestamps
    end
  end
end
