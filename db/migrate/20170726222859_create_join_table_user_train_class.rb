class CreateJoinTableUserTrainClass < ActiveRecord::Migration[5.0]
  def change
    create_join_table :users, :train_classes do |t|
      t.index [:user_id, :train_class_id]
    end
  end
end
