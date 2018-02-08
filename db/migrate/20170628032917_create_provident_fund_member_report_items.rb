class CreateProvidentFundMemberReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :provident_fund_member_report_items do |t|
      t.integer :user_id
      t.timestamps
    end
  end
end
