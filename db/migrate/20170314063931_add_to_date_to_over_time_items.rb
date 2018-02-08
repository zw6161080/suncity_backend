class AddToDateToOverTimeItems < ActiveRecord::Migration[5.0]
  def change
    add_column :over_time_items, :to_date, :datetime

  end
end
