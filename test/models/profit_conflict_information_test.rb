require "test_helper"

class ProfitConflictInformationTest < ActiveSupport::TestCase
  def profit_conflict_information
    @profit_conflict_information ||= ProfitConflictInformation.new
  end

  def test_valid
    assert profit_conflict_information.valid?
  end
end
