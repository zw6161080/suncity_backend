class CreateJoinTableUserTitle < ActiveRecord::Migration[5.0]
  def change
    create_join_table :users, :titles do |t|
      t.index [:user_id, :title_id]
    end
  end
end
