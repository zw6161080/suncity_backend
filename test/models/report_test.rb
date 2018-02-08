require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test "load predefined reports" do
    Report.load_predefined
    Report.load_predefined
    assert Report.count > 0
  end
end
