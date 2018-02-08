class AddBorrowReturnTypeToRosterObject < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_objects, :borrow_return_type, :string
  end
end
