class AddRosterRefToAttendances < ActiveRecord::Migration[5.0]
  def change
    add_reference :attendances, :roster, foreign_key: true
  end
end
