class AddOrderToBonusElement < ActiveRecord::Migration[5.0]
  def change
    add_column :bonus_elements, :order, :integer
  end
end
