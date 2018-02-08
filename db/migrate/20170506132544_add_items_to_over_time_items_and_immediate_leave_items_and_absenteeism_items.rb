class AddItemsToOverTimeItemsAndImmediateLeaveItemsAndAbsenteeismItems < ActiveRecord::Migration[5.0]
  def change
    add_column :over_time_items, :shift_info, :string
    add_column :absenteeism_items, :shift_info, :string
    add_column :immediate_leave_items, :shift_info, :string

    add_column :over_time_items, :work_time, :string
    add_column :absenteeism_items, :work_time, :string
    add_column :immediate_leave_items, :work_time, :string

    add_column :over_time_items, :come, :string
    add_column :absenteeism_items, :come, :string
    add_column :immediate_leave_items, :come, :string

    add_column :over_time_items, :leave, :string
    add_column :absenteeism_items, :leave, :string
    add_column :immediate_leave_items, :leave, :string
  end
end
