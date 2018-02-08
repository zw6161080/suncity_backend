require "test_helper"

class AirTicketReimbursementTest < ActiveSupport::TestCase
  def air_ticket_reimbursement
    @air_ticket_reimbursement ||= AirTicketReimbursement.new
  end

  def test_valid
    assert air_ticket_reimbursement.valid?
  end
end
