class CreateAirTicketReimbursements < ActiveRecord::Migration[5.0]
  def change
    create_table :air_ticket_reimbursements do |t|
      t.date :date_of_employment
      t.string :route
      t.integer :ticket_price
      t.integer :exchange_rate
      t.integer :ticket_price_macau
      t.date :apply_date
      t.date :reimbursement_date
      t.string :remarks
      t.integer :user_id

      t.timestamps
    end
  end
end
