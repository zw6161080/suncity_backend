class CreateTrainRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :train_records do |t|
      t.string :empoid
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :department_chinese_name
      t.string :department_english_name
      t.string :department_simple_chinese_name
      t.string :position_chinese_name
      t.string :position_english_name
      t.string :position_simple_chinese_name
      t.boolean :train_result
      t.decimal :attendance_rate ,precision: 15, scale: 2
      t.integer :train_id

      t.timestamps
    end
  end
end
