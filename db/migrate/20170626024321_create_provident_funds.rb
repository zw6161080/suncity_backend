class CreateProvidentFunds < ActiveRecord::Migration[5.0]
  def change
    create_table :provident_funds do |t|
      t.date :participation_date
      t.string :member_retirement_fund_number
      #税籍
      t.string :tax_registration
      t.string :icbc_account_number_mop
      t.string :icbc_account_number_rmb
      #是否是美国公民
      t.boolean :is_an_american
      #是否持有美国永久居民证
      t.boolean :has_permanent_resident_certificate

      t.string :supplier
      #平穩增長基金百分比
      t.decimal :steady_growth_fund_percentage, precision: 15, scale: 2
      #穩健基金百分比
      t.decimal :steady_fund_percentage, precision: 15, scale: 2
      #A基金百分比
      t.decimal :a_fund_percentage, precision: 15, scale: 2
      #B基金百分比
      t.decimal :b_fund_percentage, precision: 15, scale: 2
      # 公積金贖回日期
      t.date :provident_fund_resignation_date
      # 公積金贖回原因
      t.date :provident_fund_resignation_reason

      t.integer :profile_id

      t.integer :first_beneficiary_id
      t.integer :second_beneficiary_id
      t.integer :third_beneficiary_id

      t.timestamps
    end
  end
end
