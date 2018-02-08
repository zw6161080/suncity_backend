class CreateWrwts < ActiveRecord::Migration[5.0]
  def change
    #wrwt: welfare_record_without_template
    create_table :wrwts do |t|
      t.integer :user_id
      t.boolean :provide_airfare
      t.boolean :provide_accommodation
      t.timestamps
    end
  end
end
