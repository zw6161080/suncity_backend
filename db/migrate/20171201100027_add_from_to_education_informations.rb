class AddFromToEducationInformations < ActiveRecord::Migration[5.0]
  def change
    add_column :education_informations, :from_mm_yyyy, :datetime
    add_column :education_informations, :to_mm_yyyy, :datetime
  end
end
