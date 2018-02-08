class AddRecordTypeToReviseClocks < ActiveRecord::Migration[5.0]
  def change
    add_column :revise_clocks, :record_type, :string, null: false , default: 'revise_clock'
  end
end
