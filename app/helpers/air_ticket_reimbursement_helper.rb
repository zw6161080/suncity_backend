module AirTicketReimbursementHelper

  def air_ticket_params
    params.require(air_required_array)
    params.permit(air_required_array + [:remarks])
  end

  def air_required_array
    [:user_id, :date_of_employment, :route, :ticket_price, :exchange_rate,:ticket_price_macau,:apply_date,:reimbursement_date]
  end

  def air_permitted_array
    [:remarks]
  end

  def user_id_params
    params.require(:user_id)
  end

  def update_params
    required_array = [:user_id, :date_of_employment, :route, :ticket_price, :exchange_rate,:ticket_price_macau,:apply_date,:reimbursement_date]
    params.permit(required_array + [:remarks])
  end
end