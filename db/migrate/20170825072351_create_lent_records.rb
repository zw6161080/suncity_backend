class CreateLentRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :lent_records do |t|
      t.integer :user_id
      t.string :status
      t.datetime :lent_begin
      t.datetime :lent_end
      t.string :deployment_type
      t.integer :original_hall_id
      t.integer :temporary_stadium_id
      t.string :calculation_of_borrowing
      t.string :return_compensation_calculation
      t.string :comment
      t.timestamps
    end
  end
end
