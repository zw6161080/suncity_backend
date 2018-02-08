class CreateJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :jobs do |t|
      t.integer :department_id, index: true
      t.integer :position_id, index: true
      t.string :superior_email
      t.string :grade
      t.integer :number
      t.text :chinese_range
      t.text :english_range
      t.text :chinese_skill
      t.text :english_skill
      t.text :chinese_education
      t.text :english_education
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
