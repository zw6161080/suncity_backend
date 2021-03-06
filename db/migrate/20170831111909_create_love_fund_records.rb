class CreateLoveFundRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :love_fund_records do |t|
      t.integer :user_id
      t.boolean :participate
      t.datetime :participate_begin
      t.datetime :participate_end
      t.integer :creator_id
      t.timestamps
    end
  end
end
