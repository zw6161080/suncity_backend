class AddColumnToEducationInformations < ActiveRecord::Migration[5.0]
  def change
    add_column :education_informations, :highest, :boolean
  end
end
