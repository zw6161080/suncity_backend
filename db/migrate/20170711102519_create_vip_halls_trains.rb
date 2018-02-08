class CreateVipHallsTrains < ActiveRecord::Migration[5.0]
  def change
    create_table :vip_halls_trains do |t|
      t.references :location, foreign_key: true, index: true
      t.datetime :train_month
      t.boolean  :locked
      t.integer  :employee_amount
      t.integer  :training_minutes_available
      t.integer  :training_minutes_accepted
      t.integer  :training_minutes_per_employee

      t.timestamps
    end
  end
end
