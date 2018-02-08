class ChangeTimeLengthFormat < ActiveRecord::Migration[5.0]
  def change
    change_column :shifts, :time_length, 'integer USING CAST(time_length AS integer)'
  end
end
