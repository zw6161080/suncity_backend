require "test_helper"

class PaySlipTest < ActiveSupport::TestCase
  def pay_slip
    @pay_slip ||= PaySlip.new
  end

  def test_valid
    assert pay_slip.valid?
  end
end
