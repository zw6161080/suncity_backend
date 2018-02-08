class CreateSuncityCharities < ActiveRecord::Migration[5.0]
  def change
    create_table :suncity_charities do |t|
      t.string :current_status
      t.string :to_status
      t.date :valid_date
      t.integer :profile_id
      t.timestamps
    end
  end
end
