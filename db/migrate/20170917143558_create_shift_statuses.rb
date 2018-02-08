class CreateShiftStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :shift_statuses do |t|
      t.integer :user_id
      t.integer :profile_id
      t.boolean :is_shift

      t.timestamps
    end
  end
end
