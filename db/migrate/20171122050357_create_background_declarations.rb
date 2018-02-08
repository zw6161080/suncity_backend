class CreateBackgroundDeclarations < ActiveRecord::Migration[5.0]
  def change
    create_table :background_declarations do |t|
      t.integer :have_any_relatives
      t.integer :relative_criminal_record
      t.string :relative_criminal_record_detail
      t.integer :relative_business_relationship_with_suncity
      t.string :relative_business_relationship_with_suncity_detail
      t.integer :user_id

      t.timestamps
    end
  end
end
