class AddSomeFieldsToCardProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :card_profiles, :new_or_renew, :string
    add_column :card_profiles, :certificate_valid_date, :date
    add_column :card_profiles, :date_to_get_card, :date
    add_column :card_profiles, :card_valid_date, :date
  end
end
