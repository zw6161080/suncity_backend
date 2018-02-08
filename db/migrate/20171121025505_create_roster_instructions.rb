class CreateRosterInstructions < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_instructions do |t|
      t.string :comment
      t.integer :user_id
      t.timestamps
    end
  end
end
