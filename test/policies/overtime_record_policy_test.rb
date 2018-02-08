require 'test_helper'
require 'test_policy_helper'
require 'test_policy_report_helper'
class OvertimeRecordPolicyTest < ActiveSupport::TestCase
  include TestPolicyHelper
  include TestPolicyReportHelper
  def model
    OvertimeRecord
  end
  def test_scope
  end

end
