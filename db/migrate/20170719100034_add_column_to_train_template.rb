class AddColumnToTrainTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :train_templates, :simple_chinese_name, :string
  end
end
