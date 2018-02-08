require 'test_helper'

class ProfileAttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @profile = create_profile
    @profile_attachment_type = create(:profile_attachment_type)
    @current_user = create(:user)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :ProfileAttachment, :macau)

    ProfileAttachmentsController.any_instance.stubs(:current_user).returns(@current_user)
    ProfileAttachmentsController.any_instance.stubs(:authorize).returns(true)
  end

  test "get all profile attachments list with types" do

    10.times do
      the_attach = build(:profile_attachment)
      the_attach.creator = @current_user
      the_attach.profile_attachment_type = @profile_attachment_type
      @profile.profile_attachments << the_attach
    end

    @profile.user = @current_user

    get "/profiles/#{@profile.id}/profile_attachments"
    assert_response 403

    @current_user.add_role(@admin_role)
    get "/profiles/#{@profile.id}/profile_attachments"
    assert_response :success
    assert_equal json_res['data'].length, 10
  end

  test "post create one profile attachment and download file" do
    attach = create(:attachment)

    attachment_params = {
      profile_attachment_type_id: @profile_attachment_type.id,
      description: Faker::Lorem.sentence,
      attachment_id: attach.id
    }
    assert_difference('ProfileAttachment.count', 1) do
      post "/profiles/#{@profile.id}/profile_attachments", params: attachment_params, as: :json
      the_attach = @profile.profile_attachments.last.reload
      assert_equal the_attach.profile, @profile
      assert_equal the_attach.attachment, attach
      assert_equal the_attach.description, attachment_params[:description]
      assert_equal the_attach.profile_attachment_type, @profile_attachment_type
      assert_response :ok
    end

    profile_attach = @profile.profile_attachments.last
    params = {
      profile_attachment_id: profile_attach.id
    }

    get "/profiles/#{@profile.id}/profile_attachments/#{profile_attach.id}/download", params: params
    assert_equal response.header.fetch('X-Accel-Redirect'), "/internal/#{webmock_seaweed_read_url}/#{fake_seaweed_hash}?#{{filename: 'test.txt'}.to_query}"

    get "/profiles/#{@profile.id}/profile_attachments/#{profile_attach.id}/preview"
    assert json_res['state'], "error"
    assert json_res['data'].first.fetch('id'), '422'

    the_attach = profile_attach.attachment
    the_attach.preview_state = 'convert_success'
    the_attach.preview_hash = fake_seaweed_hash
    the_attach.save
    the_attach.reload

    get "/profiles/#{@profile.id}/profile_attachments/#{profile_attach.id}/preview"
    assert_equal response.header.fetch('X-Accel-Redirect'), "/internal/#{webmock_seaweed_read_url}/#{fake_seaweed_hash}?"
    assert_response :ok
  end

  test "patch update one profile attachment" do
    sample_attach = build(:profile_attachment)
    sample_attach.creator = @current_user
    sample_attach.profile_attachment_type = @profile_attachment_type
    @profile.profile_attachments << sample_attach

    another_type = create(:profile_attachment_type)
    new_description = Faker::Lorem.sentence

    assert_difference('ProfileAttachment.count', 0) do
      patch "/profiles/#{@profile.id}/profile_attachments/#{sample_attach.id}", params: {
        profile_attachment_type_id: another_type.id,
        description: new_description
      }
      sample_attach.reload
      assert_equal sample_attach.profile_attachment_type_id, another_type.id
      assert_equal sample_attach.description, new_description
      assert_response :ok
    end
  end

  test "destroy one profile attachment" do
    attach = create(:attachment)
    sample_attach = build(:profile_attachment)
    sample_attach.creator = @current_user
    sample_attach.profile_attachment_type = @profile_attachment_type
    sample_attach.attachment = attach
    @profile.profile_attachments << sample_attach

    assert_difference('ProfileAttachment.count', -1) do
      delete "/profiles/#{@profile.id}/profile_attachments/#{sample_attach.id}"
    end
    assert_response :ok
  end

end
