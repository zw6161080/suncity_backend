class CreateTrainClasses < ActiveRecord::Migration[5.0]
  def change
    create_table :train_classes do |t|
      t.datetime :begin_time
      t.datetime :end_time

      t.integer :row
      t.integer :title_id
      t.integer :train_id
      t.timestamps
    end
  end
end
