class AddMarkToSms < ActiveRecord::Migration[5.0]
  def change
    add_column :sms, :mark, :string
  end
end
