class AddNewApprovalValidDateToCardProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :card_profiles, :new_approval_valid_date, :date
  end
end
