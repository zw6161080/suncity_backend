class CreateRosterItemLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_item_logs do |t|
      t.belongs_to :roster_item
      t.belongs_to :user
      t.datetime :log_time
      t.string :log_type
      t.integer :log_type_id
      t.timestamps
    end
  end
end
