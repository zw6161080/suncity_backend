class CreateSurplusSnapshots < ActiveRecord::Migration[5.0]
  def change
    create_table :surplus_snapshots do |t|
      t.integer :user_id
      t.integer :year
      t.integer :holiday_type
      t.integer :surplus_count, default: 0

      t.timestamps
    end
  end
end
