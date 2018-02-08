class CreateRosterModels < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_models do |t|
      t.string :region
      t.string :chinese_name
      t.integer :department_id
      t.date :start_date
      t.date :end_date
      t.integer :weeks_count

      t.boolean :be_used
      t.integer :be_user_count

      t.timestamps
    end
  end
end
