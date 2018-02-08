class AddUnitToBonusElement < ActiveRecord::Migration[5.0]
  def change
    add_column :bonus_elements, :unit, :string
  end
end
