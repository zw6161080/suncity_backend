class AddOrderNoToSalaryColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_columns, :order_no, :integer
  end
end
