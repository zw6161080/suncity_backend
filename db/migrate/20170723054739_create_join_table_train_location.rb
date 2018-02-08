class CreateJoinTableTrainLocation < ActiveRecord::Migration[5.0]
  def change
    create_join_table :trains, :locations do |t|
      t.index [:train_id, :location_id]
    end
  end
end
