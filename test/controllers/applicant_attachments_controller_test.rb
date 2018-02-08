require 'test_helper'

class ApplicantAttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @applicant_profile = create_applicant_profile
    @applicant_attachment_type = create(:profile_attachment_type)
    @current_user = create(:user)

    ApplicantAttachmentsController.any_instance.stubs(:current_user_id).returns(@current_user_id_no_role)
  end

  test "get all applicant attachments list with types" do
    10.times do
      the_attach = build(:applicant_attachment)
      the_attach.creator = @current_user
      the_attach.applicant_attachment_type = @applicant_attachment_type
      @applicant_profile.applicant_attachments << the_attach
    end

    get "/applicant_profiles/#{@applicant_profile.id}/applicant_attachments"
    assert_equal json_res['data'].length, 10
  end


  test "post create one applicant attachment and download file" do
    attach = create(:attachment)

    attachment_params = {
      applicant_attachment_type_id: @applicant_attachment_type.id,
      description: Faker::Lorem.sentence,
      attachment_id: attach.id
    }

    assert_difference('ApplicantAttachment.count', 1) do
      post "/applicant_profiles/#{@applicant_profile.id}/applicant_attachments", params: attachment_params
      the_attach = @applicant_profile.applicant_attachments.last.reload
      assert_equal the_attach.applicant_profile, @applicant_profile
      assert_equal the_attach.attachment, attach
      assert_equal the_attach.description, attachment_params[:description]
      assert_equal the_attach.applicant_attachment_type, @applicant_attachment_type
      assert_response :ok
    end

    profile_attach = @applicant_profile.applicant_attachments.last
    params = {
      applicant_attachment_id: profile_attach.id
    }

    get "/applicant_profiles/#{@applicant_profile.id}/applicant_attachments/#{profile_attach.id}/download", params: params
    assert_equal response.header.fetch('X-Accel-Redirect'), "/internal/#{webmock_seaweed_read_url}/#{fake_seaweed_hash}?#{{filename: 'test.txt'}.to_query}"
  
    get "/applicant_profiles/#{@applicant_profile.id}/applicant_attachments/#{profile_attach.id}/preview"
    assert json_res['state'], "error"
    assert json_res['data'].first.fetch('id'), '422'

    the_attach = profile_attach.attachment
    the_attach.preview_state = 'convert_success'
    the_attach.preview_hash = fake_seaweed_hash
    the_attach.save
    the_attach.reload

    get "/applicant_profiles/#{@applicant_profile.id}/applicant_attachments/#{profile_attach.id}/preview"
    assert_equal response.header.fetch('X-Accel-Redirect'), "/internal/#{webmock_seaweed_read_url}/#{fake_seaweed_hash}?"
    assert_response :ok
  end

  test "patch update one applicant attachment" do
    sample_attach = build(:applicant_attachment)
    sample_attach.creator = @current_user
    sample_attach.applicant_attachment_type = @applicant_attachment_type
    @applicant_profile.applicant_attachments << sample_attach

    another_type = create(:applicant_attachment_type)
    new_description = Faker::Lorem.sentence

    assert_difference('ApplicantAttachment.count', 0) do
      patch "/applicant_profiles/#{@applicant_profile.id}/applicant_attachments/#{sample_attach.id}", params: {
        applicant_attachment_type_id: another_type.id,
        description: new_description
      }
      sample_attach.reload
      assert_equal sample_attach.applicant_attachment_type_id, another_type.id
      assert_equal sample_attach.description, new_description
      assert_response :ok
    end
  end

  test "destroy one applicant attachment" do
    attach = create(:attachment)
    sample_attach = build(:applicant_attachment)
    sample_attach.creator = @current_user
    sample_attach.applicant_attachment_type = @applicant_attachment_type
    sample_attach.attachment = attach
    @applicant_profile.applicant_attachments << sample_attach

    assert_difference('ApplicantAttachment.count', -1) do
      delete "/applicant_profiles/#{@applicant_profile.id}/applicant_attachments/#{sample_attach.id}"
    end
    assert_response :ok
  end

end
