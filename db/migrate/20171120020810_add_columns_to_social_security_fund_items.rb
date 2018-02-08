class AddColumnsToSocialSecurityFundItems < ActiveRecord::Migration[5.0]
  def change
    add_column :social_security_fund_items, :division_of_job, :string
    add_column :social_security_fund_items, :department_id, :integer
    add_column :social_security_fund_items, :position_id, :integer
    add_column :social_security_fund_items, :position_resigned_date, :datetime
    add_column :social_security_fund_items, :date_to_submit_fingermold, :datetime
    add_column :social_security_fund_items, :cancel_date, :datetime
    add_column :social_security_fund_items, :company_name, :string
    add_column :social_security_fund_items, :id_number, :integer
    add_column :social_security_fund_items, :sss_number, :integer
    add_column :social_security_fund_items, :gender, :string
    add_column :social_security_fund_items, :date_of_birth, :datetime
    add_column :social_security_fund_items, :tax_declare_date, :datetime
    add_column :social_security_fund_items, :type_of_id, :string
    add_column :social_security_fund_items, :tax_number, :datetime

  end
end
