class AddBorrowReasonAndReturnReasonAndRemoveReasonToBorrowTime < ActiveRecord::Migration[5.0]
  def change
    add_column :borrow_times, :borrow_reason, :string
    add_column :borrow_times, :return_reason, :string
    remove_column :borrow_times, :reason, :string
  end
end
