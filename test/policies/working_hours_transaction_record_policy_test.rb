require 'test_helper'
require 'test_policy_helper'
class WorkingHoursTransactionRecordPolicyTest < ActiveSupport::TestCase

  include TestPolicyHelper
  def model
    WorkingHoursTransactionRecord
  end

  def test_scope
  end
end
