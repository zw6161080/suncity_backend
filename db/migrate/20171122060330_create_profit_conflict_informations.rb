class CreateProfitConflictInformations < ActiveRecord::Migration[5.0]
  def change
    create_table :profit_conflict_informations do |t|
      t.boolean :have_or_no
      t.string :number
      t.integer :user_id

      t.timestamps
    end
  end
end
