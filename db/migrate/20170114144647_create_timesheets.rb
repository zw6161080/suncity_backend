class CreateTimesheets < ActiveRecord::Migration[5.0]
  def change
    create_table :timesheets do |t|
      t.string :year
      t.string :month
      t.belongs_to :department
      t.timestamps
    end
  end
end
