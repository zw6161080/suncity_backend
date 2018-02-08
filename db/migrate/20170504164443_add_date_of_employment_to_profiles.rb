class AddDateOfEmploymentToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :date_of_employment, :string
  end
end
