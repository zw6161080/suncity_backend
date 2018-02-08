class CreateAbsenteeismItems < ActiveRecord::Migration[5.0]
  def change
    create_table :absenteeism_items do |t|
      t.belongs_to :absenteeism
      t.text :comment
      
      t.timestamps
    end
  end
end
