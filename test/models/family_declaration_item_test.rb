require "test_helper"

class FamilyDeclarationItemTest < ActiveSupport::TestCase
  def family_declaration_item
    @family_declaration_item ||= FamilyDeclarationItem.new
  end

  def test_valid
    assert family_declaration_item.valid?
  end
end
