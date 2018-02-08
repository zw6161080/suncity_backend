require "test_helper"

class ContractInformationTypeTest < ActiveSupport::TestCase
  def contract_information_type
    @contract_information_type ||= ContractInformationType.new
  end

  def test_valid
    assert contract_information_type.valid?
  end
end
