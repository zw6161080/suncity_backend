require "test_helper"

class BackgroundDeclarationTest < ActiveSupport::TestCase
  def background_declaration
    @background_declaration ||= BackgroundDeclaration.new
  end

  def test_valid
    assert background_declaration.valid?
  end
end
