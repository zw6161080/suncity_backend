class AddColumnToPaySlips < ActiveRecord::Migration[5.0]
  def change
    add_column :pay_slips, :comment, :string
  end
end
