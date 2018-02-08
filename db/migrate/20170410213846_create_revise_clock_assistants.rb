class CreateReviseClockAssistants < ActiveRecord::Migration[5.0]
  def change
    create_table :revise_clock_assistants do |t|
      t.integer :revise_clock_item_id
      t.string :sign_time
      t.timestamps
    end
  end
end
