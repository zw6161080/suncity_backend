class CreateMessageStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :message_statuses do |t|
      t.integer :user_id
      t.integer :message_id
      t.string  :namespace
      t.boolean :has_read, default: false

      t.timestamps
    end
  end
end
