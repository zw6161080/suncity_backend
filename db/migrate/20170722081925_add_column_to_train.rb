class AddColumnToTrain < ActiveRecord::Migration[5.0]
  def change
    add_column :trains, :simple_chinese_name, :string
  end
end
