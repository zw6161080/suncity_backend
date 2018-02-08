require 'test_helper'

class DismissionSalaryItemTest < ActiveSupport::TestCase
  setup do
    create_test_user(100)
    @current_user = User.find(100)
  end

  test "should create dismission salary item after create dimission" do
    assert_difference('DismissionSalaryItem.count', 1) do
      create(:dimission, user: @current_user)
    end
  end
end
