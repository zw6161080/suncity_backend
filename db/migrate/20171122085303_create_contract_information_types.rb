class CreateContractInformationTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :contract_information_types do |t|
      t.string :chinese_name
      t.string :english_name
      t.text :description
      t.string :type

      t.timestamps
    end
  end
end
