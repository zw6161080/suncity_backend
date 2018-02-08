require 'test_helper'

class AirTicketReimbursementsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @current_user = create_test_user
  end

  def air_ticket_reimbursement
    @air_ticket_reimbursement ||= air_ticket_reimbursements :one
  end
  def user_id_params
    params.require(:user_id)
  end

  def test_index
    test_id = create_test_user.id
    params = {
        user_id:test_id,
        date_of_employment:Time.zone.now,
        route:'macau-manila',
        ticket_price:'10',
        exchange_rate:'2',
        ticket_price_macau:'20',
        apply_date:Time.zone.now,
        reimbursement_date:Time.zone.now+1.day,
        remarks:'haha',
    }
    get index_by_user_air_ticket_reimbursements_url, params: params
    assert_response :ok
  end

  def test_create
    assert_difference('AirTicketReimbursement.count') do
      post air_ticket_reimbursements_url, params: {
                                                   user_id:create_test_user.id,
                                                   date_of_employment:Time.zone.now,
                                                   route:'macau-manila',
                                                   ticket_price:'10',
                                                   exchange_rate:'2',
                                                   ticket_price_macau:'20',
                                                   apply_date:Time.zone.now,
                                                   reimbursement_date:Time.zone.now+1.day,
                                                   remarks:'haha'
      }
    end

    assert_response 201
  end

  def test_show
    test_user = create_test_user
    ar=AirTicketReimbursement.create(user_id:create_test_user.id,
                                     date_of_employment:Time.zone.now,
                                     route:'macau-manila',
                                     ticket_price:'10',
                                     exchange_rate:'2',
                                     ticket_price_macau:'20',
                                     apply_date:Time.zone.now,
                                     reimbursement_date:Time.zone.now+1.day,
                                     remarks:'haha')
    get air_ticket_reimbursement_url(ar.id)
    assert_response :ok
  end

  def _test_update
    patch air_ticket_reimbursements_url, params: {
                                                                           user_id:create_test_user.id,
                                                                           date_of_employment:Time.zone.now,
                                                                           route:'macau-manila',
                                                                           ticket_price:'10',
                                                                           exchange_rate:'2',
                                                                           ticket_price_macau:'20',
                                                                           apply_date:Time.zone.now,
                                                                           reimbursement_date:Time.zone.now+1.day,
                                                                           remarks:'haha'
                                                                          }
    assert_response 200
  end

  def _test_destroy
    assert_difference('AirTicketReimbursement.count', 0) do
      delete air_ticket_reimbursements_url
    end

    assert_response 204
  end
end

