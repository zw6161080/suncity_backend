class AddPriceToAirTicketReimbursements < ActiveRecord::Migration[5.0]
  def change
    add_column :air_ticket_reimbursements, :ticket_price, :decimal, precision: 10, scale: 2
    add_column :air_ticket_reimbursements, :exchange_rate, :decimal, precision: 10, scale: 2
    add_column :air_ticket_reimbursements, :ticket_price_macau, :decimal, precision: 10, scale: 2
  end
end
