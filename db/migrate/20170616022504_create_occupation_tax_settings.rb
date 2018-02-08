class CreateOccupationTaxSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :occupation_tax_settings do |t|
      t.decimal :deduct_percent, precision: 10, scale: 2
      t.decimal :favorable_percent, precision: 10, scale: 2
      t.jsonb :ranges

      t.timestamps
    end
  end
end
