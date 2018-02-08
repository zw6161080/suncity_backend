class AddChinSToContractInformationTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :contract_information_types, :simple_chinese_name, :string
  end
end
