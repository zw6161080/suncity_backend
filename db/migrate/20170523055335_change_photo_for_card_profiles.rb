class ChangePhotoForCardProfiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :card_profiles, :photo_id, :integer
    add_column :card_profiles, :photo_id, :string
  end
end
