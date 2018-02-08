class CreateSocialSecurityFundItems < ActiveRecord::Migration[5.0]
  def change
    create_table :social_security_fund_items do |t|
      t.references :user, foreign_key: true
      t.datetime :year_month
      t.decimal :employee_payment_mop, precision: 10, scale: 2
      t.decimal :company_payment_mop, precision: 10, scale: 2

      t.timestamps
    end
  end
end
