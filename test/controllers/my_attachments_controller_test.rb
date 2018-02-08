require 'test_helper'

class MyAttachmentsControllerTest < ActionDispatch::IntegrationTest

  def test_head_index
    test_user = create_test_user
    create(:my_attachment, user_id: test_user.id)
    MyAttachmentsController.any_instance.stubs(:current_user).returns(test_user)
    get head_index_user_my_attachments_url(user_id: test_user.id)
    assert_response :success
  end

  def test_all_index
    test_user = create_test_user
    create(:my_attachment, user_id: test_user.id)
    MyAttachmentsController.any_instance.stubs(:current_user).returns(test_user)
    get all_index_user_my_attachments_url(user_id: test_user.id)
    assert_response :success
  end

  def test_download
    test_user = create_test_user
    get download_my_attachment_url(create(:my_attachment, user_id: 1, status: :completed))
    MyAttachmentsController.any_instance.stubs(:current_user).returns(test_user)
    assert_response :success
    assert_equal response.header.fetch('X-Accel-Redirect'), nil
  end


  def test_destroy
    test_user = create_test_user
    delete my_attachment_url(create(:my_attachment, user_id: 1, status: :completed))
    MyAttachmentsController.any_instance.stubs(:current_user).returns(test_user)
    assert_response 200
  end
end
