class CreateShiftGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :shift_groups do |t|
      t.belongs_to :department
      t.string :chinese_name
      t.string :english_name
      t.text :comment
      t.jsonb :member_user_ids

      t.timestamps
    end
  end
end
