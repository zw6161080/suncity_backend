class FixColumnTypeOfSocialSecurityFundItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :social_security_fund_items, :tax_number, :datetime
    add_column :social_security_fund_items, :tax_number, :string
  end
end
