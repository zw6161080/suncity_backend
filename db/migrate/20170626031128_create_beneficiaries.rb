class CreateBeneficiaries < ActiveRecord::Migration[5.0]
  def change
    create_table :beneficiaries do |t|
      t.string :name
      t.string :certificate_type
      t.string :id_number
      t.string :relationship
      t.decimal :percentage ,precision: 15, scale: 2
      t.string  :address

      t.timestamps
    end
  end
end
