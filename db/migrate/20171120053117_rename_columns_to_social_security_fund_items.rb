class RenameColumnsToSocialSecurityFundItems < ActiveRecord::Migration[5.0]
  def change
    rename_column :social_security_fund_items, :division_of_job, :employment_status
  end
end
