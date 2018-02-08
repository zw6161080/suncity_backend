class AddCareerEntryDateToAnnualBonusItem < ActiveRecord::Migration[5.0]
  def change
    add_column :annual_bonus_items, :career_entry_date, :datetime
  end
end
