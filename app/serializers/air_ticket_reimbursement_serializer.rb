class AirTicketReimbursementSerializer < ActiveModel::Serializer
  attributes :id, :date_of_employment, :route, :ticket_price, :exchange_rate, :ticket_price_macau, :apply_date, :reimbursement_date, :remarks, :user_id
end
