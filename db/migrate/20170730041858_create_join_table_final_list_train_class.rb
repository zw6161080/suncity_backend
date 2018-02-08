class CreateJoinTableFinalListTrainClass < ActiveRecord::Migration[5.0]
  def change
    create_join_table :final_lists, :train_classes do |t|
      t.index [:final_list_id, :train_class_id], name: 'indexes_f_id_and_t_id'
    end
  end
end
