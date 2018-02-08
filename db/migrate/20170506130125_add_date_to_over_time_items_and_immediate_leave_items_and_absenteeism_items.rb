class AddDateToOverTimeItemsAndImmediateLeaveItemsAndAbsenteeismItems < ActiveRecord::Migration[5.0]
  def change
    add_column :over_time_items, :date, :Date
    add_column :absenteeism_items, :date, :Date
    add_column :immediate_leave_items, :date, :Date
  end
end
