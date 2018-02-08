class AddReasonToAwardRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :award_records, :reason, :string
  end
end
