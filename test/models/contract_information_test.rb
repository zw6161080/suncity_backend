require "test_helper"

class ContractInformationTest < ActiveSupport::TestCase
  def contract_information
    @contract_information ||= ContractInformation.new
  end

  def test_valid
    assert contract_information.valid?
  end
end
