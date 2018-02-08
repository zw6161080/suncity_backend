class CreateTrains < ActiveRecord::Migration[5.0]
  def change
    create_table :trains do |t|
      t.integer :train_template_id
      t.string :chinese_name
      t.string :english_name
      t.integer :train_number
      t.datetime :train_begin_date
      t.datetime :train_end_date
      t.string :train_place
      t.decimal :train_cost, precision:15, scale: 2
      t.datetime :registration_begin_date
      t.datetime :registration_end_date
      t.integer :registration_method
      t.integer :limit_number
      t.jsonb :grade
      t.jsonb :division_of_job
      t.string :comment
      t.integer :status





      t.timestamps
    end
  end
end
