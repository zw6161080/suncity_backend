class AddRegionToAgreements < ActiveRecord::Migration[5.0]
  def change
    add_column :agreements, :region, :string
  end
end
