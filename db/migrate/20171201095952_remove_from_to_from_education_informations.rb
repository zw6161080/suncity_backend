class RemoveFromToFromEducationInformations < ActiveRecord::Migration[5.0]
  def change
    remove_column :education_informations, :from_mm_yyyy, :date
    remove_column :education_informations, :to_mm_yyyy, :date
  end
end
