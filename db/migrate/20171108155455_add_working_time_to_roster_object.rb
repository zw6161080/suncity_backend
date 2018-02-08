class AddWorkingTimeToRosterObject < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_objects, :working_time, :string
  end
end
