class CreateSignLists < ActiveRecord::Migration[5.0]
  def change
    create_table :sign_lists do |t|
      t.integer :user_id
      t.integer :title_id
      t.integer :train_class_id
      t.integer :final_list_id
      t.integer :sign_status
      t.string :comment
      t.integer :working_status

      t.timestamps
    end
  end
end
