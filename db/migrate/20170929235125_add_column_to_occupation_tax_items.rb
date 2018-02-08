class AddColumnToOccupationTaxItems < ActiveRecord::Migration[5.0]
  def change
    add_column :occupation_tax_items, :double_pay_bonus_and_award, :decimal, precision: 15, scale: 2
  end
end
