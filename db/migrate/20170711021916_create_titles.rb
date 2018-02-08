class CreateTitles < ActiveRecord::Migration[5.0]
  def change
    create_table :titles do |t|
      t.string :name
      t.integer :col
      t.integer :train_id
      t.timestamps
    end
  end
end
