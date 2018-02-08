class CreateTyphoonSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :typhoon_settings do |t|
      t.date :start_date
      t.date :end_date

      t.datetime :start_time
      t.datetime :end_time

      t.integer :qualify_counts
      t.integer :apply_counts

      t.timestamps
    end
  end
end
