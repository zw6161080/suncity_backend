class AddSimpleChineseNameToUserAndDepartmentAndPositionAndLocation < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :simple_chinese_name, :string
    add_column :departments, :simple_chinese_name, :string
    add_column :positions, :simple_chinese_name, :string
    add_column :locations, :simple_chinese_name, :string
  end
end
