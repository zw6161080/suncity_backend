class AddUserIdToCardProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :card_profiles, :user_id, :integer
  end
end
