class CreateProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :profiles do |t|
      t.references :user, foreign_key: true
      t.string :region, index: true
      t.jsonb :data
      t.timestamps
    end
  end
end
