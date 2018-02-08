class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :empno, uniqueness: true
      t.string :chinese_name
      t.string :english_name
      t.string :password_digest, :length => 72
      t.timestamps

      t.index :empno
    end
  end
end
