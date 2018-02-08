class CreateAttendReturnApprovals < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_return_approvals do |t|
      t.integer :user_id
      t.date :date
      t.text :comment

      t.integer :return_id
      t.string  :return_type

      t.timestamps
    end
    add_index :attend_return_approvals, [:return_type, :return_id]
  end
end
