require "test_helper"

class RosterInstructionsControllerTest < ActionDispatch::IntegrationTest
  def test_update
    user = create_test_user
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :RosterInstruction, :macau)
    user.add_role(admin_role)
    roster_instruction = create(:roster_instruction, user_id: user.id, comment: 'test')
    RosterInstructionsController.any_instance.stubs(:current_user).returns(user)
    patch roster_instruction_url(roster_instruction.id), params: {comment: 'test2'}
    assert_response :ok
    assert_equal RosterInstruction.first.comment, 'test2'


  end
end
