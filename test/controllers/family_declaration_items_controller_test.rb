require 'test_helper'

class FamilyDeclarationItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @profile = create_profile
    @user1 = @profile.user
    @current_user = create(:user)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :FamilyDeclarationItem, :macau)
    FamilyDeclarationItemsController.any_instance.stubs(:current_user).returns(current_user)
    FamilyDeclarationItemsController.any_instance.stubs(:authorize).returns(true)
  end
  def family_declaration_item
    @family_declaration_item ||= family_declaration_items :one
  end
  def user_id_params
    params.require(:user_id)
  end

  def test_index_by_user
    test_id = create_test_user.id
    params = {
        profile_id: @profile.id,
        family_member_id:@user1.id,
        relative_relation:"fuzi"
    }
    get index_by_user_profile_family_declaration_items_url(params),as: :json
    assert_response :ok
  end

  def test_create
    params = {
        creator_id: create_test_user.id,
        family_member_id: @user1.id,
        relative_relation:"fuzi"
    }
    assert_difference('FamilyDeclarationItem.count') do
      post profile_family_declaration_items_url(profile_id: @profile.id), params: params
    end

    assert_response :ok
  end

  def _test_show
    get family_declaration_item_url(family_declaration_item)
    assert_response :success
  end

  def _test_update
    patch family_declaration_item_url(family_declaration_item), params: { family_declaration_item: { relative_contact_number: family_declaration_item.relative_contact_number, relative_name: family_declaration_item.relative_name, relative_relation: family_declaration_item.relative_relation, user_id: family_declaration_item.user_id } }
    assert_response 200
  end

  def _test_destroy
    assert_difference('FamilyDeclarationItem.count', -1) do
      delete family_declaration_item_url(family_declaration_item)
    end

    assert_response 204
  end
end
