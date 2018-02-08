require "test_helper"

class SignListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = Profile.find(create_profile_with_welfare_and_salary_template[:id]).user
    SignListsController.any_instance.stubs(:authorize).returns(true)
    SignListsController.any_instance.stubs(:current_user).returns(@current_user)
  end


  test 'update sign_list' do
    train =  create_train
    sign_list = create(:sign_list, user_id: @current_user.id, train_id: train.id, train_class_id: train.train_classes.first.id)

    params = {
        operator: 'hr',
        sign_status: 'attend',
        comment: 'test'
    }

    patch sign_list_url(sign_list.id), params: params , as: :json
    assert_response :ok
    assert_equal SignList.first.sign_status, 'attend'
    assert_equal SignList.first.comment, 'test'
  end
end
