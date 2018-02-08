class CreateAwardRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :award_records do |t|
      t.integer :user_id
      t.datetime :year
      t.string :content
      t.datetime :award_date
      t.string :comment
      t.integer :creator_id
      t.timestamps
    end
  end
end
