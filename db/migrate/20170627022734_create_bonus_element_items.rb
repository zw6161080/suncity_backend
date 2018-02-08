class CreateBonusElementItems < ActiveRecord::Migration[5.0]
  def change
    create_table :bonus_element_items do |t|
      t.references :user, foreign_key: true
      t.datetime :year_month

      t.timestamps
    end
  end
end
