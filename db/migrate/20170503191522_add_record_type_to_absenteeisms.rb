class AddRecordTypeToAbsenteeisms < ActiveRecord::Migration[5.0]
  def change
    add_column :absenteeisms, :record_type, :string, null: false , default: 'absenteeism'
  end
end

