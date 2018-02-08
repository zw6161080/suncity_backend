class CreateStoredSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :stored_settings do |t|
      t.string     :var,    :null => false
      t.text       :value

      t.timestamps :null => true
    end
    
    add_index :stored_settings, :var, :unique => true
  end
end
