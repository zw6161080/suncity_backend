class RemovePriceFromAirTicketReimbursements < ActiveRecord::Migration[5.0]
  def change
    remove_column :air_ticket_reimbursements, :ticket_price, :integer
    remove_column :air_ticket_reimbursements, :exchange_rate, :integer
    remove_column :air_ticket_reimbursements, :ticket_price_macau, :integer
  end
end
