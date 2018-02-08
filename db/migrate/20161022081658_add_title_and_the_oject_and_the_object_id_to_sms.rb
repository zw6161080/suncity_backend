class AddTitleAndTheOjectAndTheObjectIdToSms < ActiveRecord::Migration[5.0]
  def change
    add_column :sms, :title, :string
    add_column :sms, :the_object, :string
    add_column :sms, :the_object_id, :integer
  end
end
