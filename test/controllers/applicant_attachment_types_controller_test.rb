require 'test_helper'

class ApplicantAttachmentTypesControllerTest < ActionDispatch::IntegrationTest
   setup do
    current_user = create(:user)
    ApplicantAttachmentTypesController.any_instance.stubs(:current_user).returns(current_user)
    ApplicantAttachmentTypesController.any_instance.stubs(:authorize).returns(true)
  end

  test "get all applicant attachment types list" do
    10.times do
      create(:applicant_attachment_type)
    end

    ApplicantAttachmentType.first.applicant_attachments.new.save

    get '/applicant_attachment_types'
    assert_response :ok
    assert_equal json_res['data'].count, 10
    assert_equal json_res['data'].first.fetch('can_delete?'), false
  end


  test "post create one applicant attachment type" do
    sample_type = build(:applicant_attachment_type)

    assert_difference('ApplicantAttachmentType.count', 1) do
      post '/applicant_attachment_types', params: { 
        chinese_name: sample_type.chinese_name,
        english_name: sample_type.english_name,
        description: sample_type.description
      }
      assert_response :ok
    end
  end

  test "get show one applicant attachment type" do
    sample_type = create(:applicant_attachment_type)

    get "/applicant_attachment_types/#{sample_type.id}"
    assert_equal sample_type.id, json_res['data']['id']
    assert_response :ok
  end

  test "patch update one applicant attachment type" do
    sample_type = create(:applicant_attachment_type)
    new_chinese_name = Faker::Lorem.word
    new_english_name = Faker::Lorem.word
    new_description = Faker::Lorem.sentence

    assert_difference('ApplicantAttachmentType.count', 0) do
      patch "/applicant_attachment_types/#{sample_type.id}", params: {
        chinese_name: new_chinese_name,
        english_name: new_english_name,
        description: new_description
      }
      sample_type.reload
      assert_equal sample_type.chinese_name, new_chinese_name
      assert_equal sample_type.english_name, new_english_name
      assert_equal sample_type.description, new_description
      assert_response :ok
    end
  end

  test "destroy one applicant attachment type" do
    sample_type = create(:applicant_attachment_type)
    assert_difference('ApplicantAttachmentType.count', -1) do
      delete "/applicant_attachment_types/#{sample_type.id}"
    end
    assert_response :ok

    sample_type = create(:applicant_attachment_type)
    sample_type.applicant_attachments << ApplicantAttachment.new

    assert_difference('ApplicantAttachmentType.count', 0) do
      delete "/applicant_attachment_types/#{sample_type.id}"
    end
  end
end
