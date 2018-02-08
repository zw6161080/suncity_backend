class AddFixedGroupToRole < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :key, :string
    add_column :roles, :fixed, :boolean
    add_column :roles, :simple_chinese_name, :string
    add_column :roles, :introduction_chinese_name, :string
    add_column :roles, :introduction_english_name, :string
    add_column :roles, :introduction_simple_chinese_name, :string
  end
end
