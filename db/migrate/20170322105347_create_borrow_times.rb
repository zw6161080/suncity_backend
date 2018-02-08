class CreateBorrowTimes < ActiveRecord::Migration[5.0]
  def change
    create_table :borrow_times do |t|
      t.integer :record_type, null: false
      t.integer :borrow_type, null: false

      t.integer :user_id, null: false
      t.integer :borrower_id

      t.string :borrow_date, null: false
      t.string :borrow_from, null: false
      t.string :borrow_to, null: false
      t.string :borrow_input_date
      t.integer :borrow_creator_id

      t.string :return_date
      t.string :return_from
      t.string :return_to
      t.string :return_input_date
      t.integer :return_creator_id

      t.string :reason, null: false
      t.string :borrow_comment
      t.string :return_comment
      t.timestamps
    end
  end
end
