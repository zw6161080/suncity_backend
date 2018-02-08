class CreateRosterSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_settings do |t|
      t.references :roster, foreign_key: true
      t.jsonb :shift_interval_hour
      t.jsonb :rest_number
      t.jsonb :rest_interval_day
      t.jsonb :shift_type_number

      t.timestamps
    end
  end
end
