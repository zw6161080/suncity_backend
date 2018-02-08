class CreateSms < ActiveRecord::Migration[5.0]
  def change
    create_table :sms do |t|
      t.string :to
      t.text :content
      t.belongs_to :user

      t.timestamps
    end
  end
end
