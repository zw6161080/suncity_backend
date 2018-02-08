class AddColumnToOccupationTaxItems1 < ActiveRecord::Migration[5.0]
  def change
    add_column :occupation_tax_items, :department_id, :integer
    add_column :occupation_tax_items, :position_id, :integer
  end
end
