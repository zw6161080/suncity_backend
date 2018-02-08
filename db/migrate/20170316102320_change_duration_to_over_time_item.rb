class ChangeDurationToOverTimeItem < ActiveRecord::Migration[5.0]
  def change
    change_column :over_time_items, :duration, :float
  end
end
