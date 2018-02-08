class CreateMuseumRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :museum_records do |t|
      t.integer :user_id
      t.string :status
      t.datetime :date_of_employment
      t.string :deployment_type
      t.string :salary_calculation
      t.integer :location_id
      t.string :comment
      t.timestamps
    end
  end
end
