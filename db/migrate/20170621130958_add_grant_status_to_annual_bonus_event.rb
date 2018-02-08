class AddGrantStatusToAnnualBonusEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :annual_bonus_events, :grant_status, :string
  end
end
