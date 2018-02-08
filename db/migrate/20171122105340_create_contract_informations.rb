class CreateContractInformations < ActiveRecord::Migration[5.0]
  def change
    create_table :contract_informations do |t|
      t.integer :profile_id
      t.integer :contract_information_type_id
      t.integer :attachment_id
      t.text :description
      t.integer :creator_id
      t.string :file_name

      t.timestamps
    end
  end
end
