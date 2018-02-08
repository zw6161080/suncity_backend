class CreateJoinTableTrainUser < ActiveRecord::Migration[5.0]
  def change
    create_join_table :trains, :users do |t|
      t.index [:train_id, :user_id]
    end
  end
end
