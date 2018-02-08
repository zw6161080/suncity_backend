class CreateLentTemporarilyApplies < ActiveRecord::Migration[5.0]
  def change
    create_table :lent_temporarily_applies do |t|
      t.string :region
      t.date :apply_date
      t.text :comment
      t.integer :creator_id

      t.timestamps
    end
  end
end
