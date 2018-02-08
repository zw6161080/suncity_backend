class AddUserIdToReviseClockItems < ActiveRecord::Migration[5.0]
  def change
    add_column :revise_clock_items, :user_id, :integer
  end
end
