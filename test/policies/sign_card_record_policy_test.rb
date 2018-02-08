require 'test_helper'
require 'test_policy_helper'
require 'test_policy_report_helper'
class SignCardRecordPolicyTest < ActiveSupport::TestCase
  include TestPolicyHelper
  include TestPolicyReportHelper
  def model
    SignCardRecord
  end

  def test_scope
  end



end
