class CreateImmediateLeaveItems < ActiveRecord::Migration[5.0]
  def change
    create_table :immediate_leave_items do |t|
      t.belongs_to :immediate_leave
      t.text :comment

      t.timestamps
    end
  end
end
