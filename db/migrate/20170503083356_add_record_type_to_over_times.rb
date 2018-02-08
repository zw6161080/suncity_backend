class AddRecordTypeToOverTimes < ActiveRecord::Migration[5.0]
  def change
    add_column :over_times, :record_type, :string, null: false , default: 'over_time'
  end
end
