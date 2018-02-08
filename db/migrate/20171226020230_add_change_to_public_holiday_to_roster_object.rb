class AddChangeToPublicHolidayToRosterObject < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_objects, :change_to_general_holiday, :boolean
  end
end
