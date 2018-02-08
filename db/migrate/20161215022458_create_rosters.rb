class CreateRosters < ActiveRecord::Migration[5.0]
  def change
    create_table :rosters do |t|
      t.belongs_to :department
      t.string :state
      t.string :year
      t.string :month
      t.string :region

      t.daterange :availability

      t.jsonb :shift_interval
      t.jsonb :rest_day_amount_per_week
      t.jsonb :rest_day_interval
      t.jsonb :in_between_rest_day_shift_type_amount
      t.timestamps
    end

    add_index :rosters, [:year, :month]
    add_index :rosters, [:year, :month, :department_id], unique: true
    add_index :rosters, :region
    add_index :rosters, :availability
  end
end
