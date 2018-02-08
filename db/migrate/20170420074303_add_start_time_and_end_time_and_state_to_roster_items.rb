class AddStartTimeAndEndTimeAndStateToRosterItems < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_items, :start_time, :datetime
    add_column :roster_items, :end_time, :datetime
    add_column :roster_items, :state, :integer, default: 0
  end
end
