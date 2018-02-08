class CerateContracts < ActiveRecord::Migration[5.0]
  def change
    create_table :contracts do |t|
      t.integer :applicant_position_id
      t.string :time
      t.text :comment
      t.text :comment
      t.integer :status
      t.text :cancel_reason

      t.timestamps
    end
  end
end
