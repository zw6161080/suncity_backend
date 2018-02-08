class CreateTyphoonQualifiedRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :typhoon_qualified_records do |t|
      t.string :region
      t.integer :typhoon_setting_id
      t.integer :user_id

      t.boolean :is_compensate

      t.date :qualify_date
      t.integer :money
      t.boolean :is_apply

      t.string :working_hours

      t.timestamps
    end
  end
end
