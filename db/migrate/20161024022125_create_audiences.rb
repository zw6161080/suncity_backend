class CreateAudiences < ActiveRecord::Migration[5.0]
  def change
    create_table :audiences do |t|
      t.integer :applicant_position_id
      t.integer :status, default: 0
      t.text :comment

      t.timestamps
    end
  end
end
