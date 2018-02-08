class AddRecordTypeToImmediateLeaves < ActiveRecord::Migration[5.0]
  def change
    add_column :immediate_leaves, :record_type, :string, null: false , default: 'immediate_leave'
  end
end
