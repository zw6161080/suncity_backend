class AddAllowBeLateMinuteAndAllowLeaveEarlyMinuteToShifts < ActiveRecord::Migration[5.0]
  def change
    add_column :shifts, :allow_be_late_minute, :integer
    add_column :shifts, :allow_leave_early_minute, :integer

    add_column :shifts, :shift_interval_hour, :jsonb
    add_column :shifts, :rest_number, :jsonb
    add_column :shifts, :rest_interval_day, :jsonb
    add_column :shifts, :shift_type_number, :jsonb

    remove_column :shifts, :min_workers_number , :integer
    remove_column :shifts, :min_3_leval_workers_number, :integer
    remove_column :shifts, :min_4_leval_workers_number, :integer
  end
end
