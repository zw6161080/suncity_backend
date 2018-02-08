class CreateAttendApprovals < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_approvals do |t|
      t.integer :user_id
      t.date :date
      t.text :comment

      t.integer :approvable_id
      t.string  :approvable_type

      t.timestamps
    end

    add_index :attend_approvals, [:approvable_type, :approvable_id]

  end
end
