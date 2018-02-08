require "test_helper"

class FinalListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = Profile.find(create_profile_with_welfare_and_salary_template[:id]).user
    FinalListsController.any_instance.stubs(:authorize).returns(true)
    FinalListsController.any_instance.stubs(:current_user).returns(@current_user)
  end

  test 'should patch update' do
    train = create_train

    train.titles << create(:title, col: 2, name: 'test', train_id: train.id)
    train.train_classes << test_train_class_1 = create(:train_class, title_id: train.titles.last.id, row: 2)
    final_list =  FinalList.create(user_id: @current_user.id, train_id: train.id)
    final_list.train_classes << train.train_classes.first
    params = [test_train_class_1.id]
    patch final_list_url(final_list.id), params: params, as: :json
    assert_response :ok
    assert_equal FinalList.last.train_classes.first.id, test_train_class_1.id
    params = {
      train_result: :train_not_pass,
      comment: 'test'
    }
    patch train_result_final_list_url(final_list.id), params: params, as: :json
    assert_response :ok
    assert_equal FinalList.last.train_result.to_sym, :train_not_pass
    assert_equal FinalList.last.comment, nil
  end
end
