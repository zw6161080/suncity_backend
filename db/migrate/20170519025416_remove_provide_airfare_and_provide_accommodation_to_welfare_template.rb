class RemoveProvideAirfareAndProvideAccommodationToWelfareTemplate < ActiveRecord::Migration[5.0]
  def change
    remove_column :welfare_templates, :provide_airfare, :boolean
    remove_column :welfare_templates, :provide_accommodation, :boolean
  end
end
