require 'test_helper'

class AppraisalAttachmentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    seaweed_webmock
    AppraisalBasicSetting.load_predefined
    @appraisal_basic_setting = AppraisalBasicSetting.all.first
    @current_user = create_test_user
    AppraisalAttachmentsController.any_instance.stubs(:current_user).returns(@current_user)
    AppraisalAttachmentsController.any_instance.stubs(:authorize).returns(true)
  end

  test "should index" do
    get appraisal_basic_setting_attachments_url, as: :json
    assert_response :success
  end

  test "should update" do
    attach = create(:attachment)
    another_attach = create(:attachment)

    create_params = {
      appraisal_basic_setting_id: @appraisal_basic_setting.id,
      attachment_id: attach.id,
      file_name: 'cecece',
      file_type: '封面',
      comment: Faker::Lorem.sentence
    }
    post appraisal_basic_setting_attachments_url, params: create_params
    assert_response :success

    attach = @appraisal_basic_setting.appraisal_attachments.last.reload
    update_params = {
      attachment_id: another_attach.id,
      file_name: 'new_name',
      file_type: '封皮',
      comment: 'wawawawawa'
    }
    patch "/appraisal_basic_setting/attachments/#{attach.id}", params: update_params, as: :json
    assert_response :success
    attach = @appraisal_basic_setting.appraisal_attachments.find(attach.id)
    assert_equal attach.attachment_id, another_attach.id
    assert_equal attach.file_name, 'new_name'
    assert_equal attach.file_type, '封皮'
    assert_equal attach.comment, 'wawawawawa'

    update_params = {
        attachment_id: 123,
        file_name: 'new_name',
        file_type: '封皮',
        comment: 'wawawawawa'
    }
    patch "/appraisal_basic_setting/attachments/#{attach.id}", params: update_params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '相关文件不存在'
  end

  test "should destory" do
    attach = create(:attachment)
    attachment_params = {
      appraisal_basic_setting_id: @appraisal_basic_setting.id,
      attachment_id: attach.id,
      file_name: 'cecece',
      file_type: '封面',
      comment: Faker::Lorem.sentence
    }
    assert_difference('AppraisalAttachment.count', 1) do
      post appraisal_basic_setting_attachments_url, params: attachment_params
    end
    assert_response :success

    appraisal_attachment = @appraisal_basic_setting.appraisal_attachments.last.reload
    assert_difference('AppraisalAttachment.count', -1) do
      delete "/appraisal_basic_setting/attachments/#{appraisal_attachment.id}"
    end
    assert_response :success

  end

  test "should create" do
    attach = create(:attachment)
    attachment_params = {
      appraisal_basic_setting_id: @appraisal_basic_setting.id,
      attachment_id: attach.id,
      file_name: 'cecece',
      file_type: '封面',
      comment: Faker::Lorem.sentence,
      creator_id: @current_user.id
    }
    post appraisal_basic_setting_attachments_url, params: attachment_params
    assert_response :success

    attach = @appraisal_basic_setting.appraisal_attachments.last.reload
    assert_equal attach.file_name, 'cecece'
    assert_equal attach.file_type, '封面'
    assert_equal attach.comment, attachment_params[:comment]

    attachment_params = {
        appraisal_basic_setting_id: @appraisal_basic_setting.id,
        attachment_id: 123,
        file_name: 'cecece',
        file_type: '封面',
        comment: Faker::Lorem.sentence,
        creator_id: @current_user.id
    }
    post appraisal_basic_setting_attachments_url, params: attachment_params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '相关文件不存在'

  end

end
