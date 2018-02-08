class AddCareerEntryDateAndEmployeeTypeToSocialSecurityFundItem < ActiveRecord::Migration[5.0]
  def change
    add_column :social_security_fund_items, :career_entry_date, :datetime
    add_column :social_security_fund_items, :employee_type, :string
  end
end
