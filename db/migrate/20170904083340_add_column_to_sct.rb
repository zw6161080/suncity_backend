class AddColumnToSct < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_column_templates, :default, :boolean
  end
end
