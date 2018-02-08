class CreateOverTimeItems < ActiveRecord::Migration[5.0]
  def change
    create_table :over_time_items do |t|
      t.belongs_to :over_time
      t.integer :over_time_type
      t.integer :make_up_type
      t.string :from
      t.string :to
      t.integer :duration

      t.timestamps
    end
  end
end
