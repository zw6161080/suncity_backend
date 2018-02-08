class AddInputDateToSignCardRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :sign_card_records, :input_date, :date
    add_column :sign_card_records, :input_time, :string
  end
end
