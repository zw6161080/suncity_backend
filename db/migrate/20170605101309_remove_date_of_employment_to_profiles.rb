class RemoveDateOfEmploymentToProfiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :profiles, :date_of_employment, :string
  end
end
