class AddStatusToSms < ActiveRecord::Migration[5.0]
  def change
    add_column :sms, :status, :integer, default: 0
  end
end
