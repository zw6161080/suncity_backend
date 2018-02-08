class CreateBonusElementSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :bonus_element_settings do |t|
      t.references :department, foreign_key: true
      t.references :location, foreign_key: true
      t.references :bonus_element, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
