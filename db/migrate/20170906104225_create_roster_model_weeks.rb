class CreateRosterModelWeeks < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_model_weeks do |t|
      t.string :region
      t.integer :roster_model_id

      t.integer :order_no
      t.integer :mon_roster_object_id
      t.integer :tue_roster_object_id
      t.integer :wed_roster_object_id
      t.integer :thu_roster_object_id
      t.integer :fri_roster_object_id
      t.integer :sat_roster_object_id
      t.integer :sun_roster_object_id

      t.timestamps
    end
  end
end
