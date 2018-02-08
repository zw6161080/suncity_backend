require 'test_helper'

class ApplicantPositionAgreementFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @applicant_position = create(:applicant_position)
    @applicant_position.applicant_profile = create_applicant_profile
    @applicant_position.department = create(:department)
    @applicant_position.position = create(:position)
    @applicant_position.save
byebug
    attachment = create(:attachment, seaweed_hash: '2,aabbccdd112233', file_name: 'test_agreement_template.docx')
    # agreement = create(:agreement, title: 'test', attachment_id: attachment.id, region: 'macau')
    agreement_file_attachment = create(:attachment)
    user = create(:user)
    agreement_file = create(:agreement_file, creator_id: user.id, file_key: 'temp_1', applicant_position_id: @applicant_position.id, attachment_id: agreement_file_attachment.id)
  
    current_user = create(:user)
    ApplicantPositionAgreementFilesController.any_instance.stubs(:current_user).returns(current_user)
    ApplicantPositionAgreementFilesController.any_instance.stubs(:authorize).returns(true)
  end

  test "get applicant_position_agreement_files index" do
    get "/applicant_positions/#{@applicant_position.id}/agreement_files"

    assert_response :ok
    assert_equal json_res['data'].first.fetch('id'), AgreementFile.last.id
  end

  test "test post generate and get download and destroy" do
    params = {
      region: 'macau',
      file_key: "temp_8",
      data: {chinese_name: '中文名'}
    }
    seaweed_webmock

    assert_difference(['AgreementFile.count', 'ApplicationLog.count', 'Attachment.count'], 1) do
      post  "/applicant_positions/#{@applicant_position.id}/agreement_files/generate", params: params
      assert_response :ok
      assert_equal json_res['data']['file_key'], params[:file_key]
    end

    new_id = AgreementFile.last.id
    get "/applicant_positions/#{@applicant_position.id}/agreement_files/#{new_id}/download"
    assert_equal response.header.fetch('X-Accel-Redirect'), "/internal/#{webmock_seaweed_read_url}/#{fake_seaweed_hash}?#{{filename: AgreementFile.last.attachment.file_name}.to_query}"

    assert_difference(['ApplicationLog.count'], 1) do
      assert_difference(['AgreementFile.count', 'Attachment.count'], -1) do
        delete "/applicant_positions/#{@applicant_position.id}/agreement_files/#{new_id}"
        assert_response :ok
      end
    end

  end

  test "test get file_list" do
    get "/agreement_files/file_list", params: {region: 'macau'}
    assert_response :ok
    assert_equal 12, json_res['data'].length

    get "/agreement_files/file_list", params: {region: 'manila'}
    assert_response :ok
    assert_equal 12, json_res['data'].length
  end
end
