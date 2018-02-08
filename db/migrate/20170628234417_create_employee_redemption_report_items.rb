class CreateEmployeeRedemptionReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_redemption_report_items do |t|
      t.integer :user_id
      t.string :contribution_item
      t.decimal :vesting_percentage
      t.timestamps
    end
  end
end
