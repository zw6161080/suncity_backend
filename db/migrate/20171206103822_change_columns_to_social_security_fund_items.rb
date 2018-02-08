class ChangeColumnsToSocialSecurityFundItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :social_security_fund_items, :id_number, :integer
    remove_column :social_security_fund_items, :sss_number, :integer
    add_column :social_security_fund_items, :id_number, :string
    add_column :social_security_fund_items, :sss_number, :string
  end
end
