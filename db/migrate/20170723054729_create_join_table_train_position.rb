class CreateJoinTableTrainPosition < ActiveRecord::Migration[5.0]
  def change

    create_join_table :trains, :positions do |t|
      t.index [:train_id, :position_id]
    end
  end
end
