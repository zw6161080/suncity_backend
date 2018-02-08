class CreateAttendances < ActiveRecord::Migration[5.0]
  def change
    create_table :attendances do |t|
      t.belongs_to :department
      t.belongs_to :location
      t.string :year
      t.string :month
      t.string :region

      t.integer :snapshot_employees_count
      t.integer :rosters
      t.integer :public_holidays
      t.integer :attendance_record
      t.integer :unusual_attendances

      t.timestamps
    end

    add_index :attendances, [:year, :month]
    add_index :attendances, [:year, :month, :department_id]
    add_index :attendances, [:year, :month, :location_id]
    add_index :attendances,
              [:year, :month, :department_id, :location_id],
              unique: true,
              name: 'all'
    add_index :attendances, :region
  end
end
