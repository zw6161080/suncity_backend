class CreateJoinTableLocationPosition < ActiveRecord::Migration[5.0]
  def change
    create_join_table :locations, :positions do |t|
      t.index [:location_id, :position_id]
    end
  end
end
