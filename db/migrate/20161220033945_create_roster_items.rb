class CreateRosterItems < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_items do |t|
      t.belongs_to :user
      t.belongs_to :shift
      t.belongs_to :roster
      t.date :date
      t.timestamps
    end
  end
end
