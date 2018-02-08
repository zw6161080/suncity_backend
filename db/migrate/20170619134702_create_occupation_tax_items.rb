class CreateOccupationTaxItems < ActiveRecord::Migration[5.0]
  def change
    create_table :occupation_tax_items do |t|
      t.references :user, foreign_key: true
      t.datetime :year

      t.string :month_1_company
      t.decimal :month_1_income_mop, precision: 15, scale: 2
      t.decimal :month_1_tax_mop, precision: 15, scale: 2

      t.string :month_2_company
      t.decimal :month_2_income_mop, precision: 15, scale: 2
      t.decimal :month_2_tax_mop, precision: 15, scale: 2

      t.string :month_3_company
      t.decimal :month_3_income_mop, precision: 15, scale: 2
      t.decimal :month_3_tax_mop, precision: 15, scale: 2

      t.decimal :quarter_1_income_mop, precision: 15, scale: 2
      t.decimal :quarter_1_tax_mop_before_adjust, precision: 15, scale: 2
      t.decimal :quarter_1_tax_mop_after_adjust, precision: 15, scale: 2

      t.string :month_4_company
      t.decimal :month_4_income_mop, precision: 15, scale: 2
      t.decimal :month_4_tax_mop, precision: 15, scale: 2

      t.string :month_5_company
      t.decimal :month_5_income_mop, precision: 15, scale: 2
      t.decimal :month_5_tax_mop, precision: 15, scale: 2

      t.string :month_6_company
      t.decimal :month_6_income_mop, precision: 15, scale: 2
      t.decimal :month_6_tax_mop, precision: 15, scale: 2

      t.decimal :quarter_2_income_mop, precision: 15, scale: 2
      t.decimal :quarter_2_tax_mop_before_adjust, precision: 15, scale: 2
      t.decimal :quarter_2_tax_mop_after_adjust, precision: 15, scale: 2

      t.string :month_7_company
      t.decimal :month_7_income_mop, precision: 15, scale: 2
      t.decimal :month_7_tax_mop, precision: 15, scale: 2

      t.string :month_8_company
      t.decimal :month_8_income_mop, precision: 15, scale: 2
      t.decimal :month_8_tax_mop, precision: 15, scale: 2

      t.string :month_9_company
      t.decimal :month_9_income_mop, precision: 15, scale: 2
      t.decimal :month_9_tax_mop, precision: 15, scale: 2

      t.decimal :quarter_3_income_mop, precision: 15, scale: 2
      t.decimal :quarter_3_tax_mop_before_adjust, precision: 15, scale: 2
      t.decimal :quarter_3_tax_mop_after_adjust, precision: 15, scale: 2

      t.string :month_10_company
      t.decimal :month_10_income_mop, precision: 15, scale: 2
      t.decimal :month_10_tax_mop, precision: 15, scale: 2

      t.string :month_11_company
      t.decimal :month_11_income_mop, precision: 15, scale: 2
      t.decimal :month_11_tax_mop, precision: 15, scale: 2

      t.string :month_12_company
      t.decimal :month_12_income_mop, precision: 15, scale: 2
      t.decimal :month_12_tax_mop, precision: 15, scale: 2

      t.decimal :quarter_4_income_mop, precision: 15, scale: 2
      t.decimal :quarter_4_tax_mop_before_adjust, precision: 15, scale: 2

      t.decimal :year_income_mop, precision: 15, scale: 2
      t.decimal :year_payable_tax_mop, precision: 15, scale: 2
      t.decimal :year_paid_tax_mop, precision: 15, scale: 2

      t.decimal :quarter_4_tax_mop_after_adjust, precision: 15, scale: 2

      t.string :comment

      t.timestamps
    end
  end
end
