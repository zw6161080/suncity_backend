class CreateEntryLists < ActiveRecord::Migration[5.0]
  def change
    create_table :entry_lists do |t|
      t.datetime :registration_time
      t.string :datetime
      t.integer :user_id
      t.boolean :is_can_be_absent
      t.integer :working_status
      t.integer :title_class_id
      t.integer :is_in_working_time
      t.integer :registration_status
      t.string :creator_id
      t.string :integer
      t.string :change_reason
      t.string :string
      t.integer :train_id

      t.timestamps
    end
  end
end
