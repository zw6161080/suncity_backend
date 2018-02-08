require "test_helper"

class EntryListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_test_user
    EntryListsController.any_instance.stubs(:authorize).returns(true)
    EntryListsController.any_instance.stubs(:current_user).returns(@user)
  end


  test ' entry_list with cancel_the_registration' do
    train = create_train
    post can_create_entry_lists_url, params: {
      user_id: @user.id,
      title_id: train.titles.first.id,
      operation: 'by_hr',
      train_id: train.id
    }
    assert_response :ok
byebug
    post entry_lists_url, params: {
        user_id: @user.id,
        title_id: train.titles.first.id,
        operation: 'by_hr',
        train_id: train.id
    }
    assert_response :ok

    assert_equal json_res['data'], EntryList.last.id
    assert_equal EntryList.last.registration_status, 'staff_registration'

    post entry_lists_url, params: {
        user_id: @user.id,
        title_id: train.titles.first.id,
        operation: 'by_hr',
        train_id: train.id
    }
    assert_response 422
    train.titles.create(col: 2, name: 'test1')
    params = {
        id: EntryList.last.id,
        title_id: train.titles.last.id,
        change_reason: 'title_change',
        edit_action: 'update_title',
        operator: 'hr'
    }

    patch entry_list_url(params), as: :json
    assert_response :ok
    assert_equal EntryList.last.change_reason, 'title_change'
    assert_equal EntryList.last.title_id, train.titles.last.id

    EntryList.last.update(registration_status: 'cancel_the_registration')
    post entry_lists_url, params: {
        user_id: @user.id,
        operation: 'by_hr',
        train_id: train.id
    }

    assert_response :ok
    assert_equal EntryList.last.registration_status, 'staff_registration'

  end

  test 'should create entry_list and update entry_list and generate final_lists' do
    train = create_train
    post entry_lists_url, params: {
        user_id: @user.id,
        title_id: train.titles.first.id,
        operation: 'by_hr',
        train_id: train.id
    }
    assert_response :ok

    assert_equal json_res['data'], EntryList.last.id
    assert_equal EntryList.last.registration_status, 'staff_registration'

    post entry_lists_url, params: {
        user_id: @user.id,
        title_id: train.titles.first.id,
        operation: 'by_hr',
        train_id: train.id
    }
    assert_response 422
    train.titles.create(col: 2, name: 'test1')
    params = {
        id: EntryList.last.id,
        title_id: train.titles.last.id,
        change_reason: 'title_change',
        edit_action: 'update_title',
        operator: 'hr'
    }

    patch entry_list_url(params), as: :json
    assert_response :ok
    assert_equal EntryList.last.change_reason, 'title_change'
    assert_equal EntryList.last.title_id, train.titles.last.id

    EntryList.last.update(registration_status: 'invitation_to_be_confirmed')
    params = {
        id: EntryList.last.id,
        edit_action: 'accept',
        operator: 'employee'
    }

    patch entry_list_url(params), as: :json
    assert_response :ok
    assert_equal EntryList.last.registration_status, 'invite_to_register'

    params = {
        id: EntryList.last.id,
        edit_action: 'cancel',
        change_reason: 'cancel',
        operator: 'employee'
    }

    patch entry_list_url(params), as: :json
    assert_response :ok
    assert_equal EntryList.last.registration_status, 'cancel_the_registration'
    assert_equal EntryList.last.change_reason, "title_change,cancel"
    params = {
        update: [{
                     id: EntryList.last.id,
                     change_reason: 'update',
                     title_id: train.titles.first.id,
        }],
        create: [
            EntryList.last.id
        ]
    }

    patch batch_update_and_to_final_lists_entry_lists_url, params: params, as: :json
    assert_response :ok
    assert_equal FinalList.last.train_result, 'train_pass'
    assert_equal FinalList.last.cost.to_s, '2000.0'
    assert_equal FinalList.last.train_classes.first, EntryList.last.title.train_classes.first
    assert_equal EntryList.last.title_id, train.titles.first.id
    assert_equal EntryList.last.change_reason, 'title_change,cancel,update'
    assert_equal SignList.first.train_class_id,  FinalList.last.train_classes.first.id
    assert_equal EntryList.last.train.users.first.id, FinalList.last.user.id

    byebug

  end


end
