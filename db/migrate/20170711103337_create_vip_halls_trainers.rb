class CreateVipHallsTrainers < ActiveRecord::Migration[5.0]
  def change
    create_table :vip_halls_trainers do |t|
      t.references :vip_halls_train, foreign_key: true, index: true
      t.datetime   :train_date_begin
      t.datetime   :train_date_end
      t.integer    :length_of_training_time
      t.string     :train_content
      t.references :user, foreign_key: true, index: true
      t.string     :train_type
      t.integer    :number_of_students
      t.integer    :total_accepted_training_time
      t.string     :remarks

      t.timestamps
    end
  end
end
