require 'test_helper'

class ContractInformationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @profile = create_profile
    @contract_information_type = create(:contract_information_type)
    @current_user = create(:user)
    ContractInformationsController.any_instance.stubs(:current_user).returns(@current_user)
    ContractInformationsController.any_instance.stubs(:authorize).returns(true)
  end

  test "get all contract informations list with types" do

    10.times do
      the_attach = build(:contract_information)
      the_attach.creator = @current_user
      the_attach.contract_information_type = @contract_information_type
      @profile.contract_informations << the_attach
    end

    @profile.user = @current_user

    get "/profiles/#{@profile.id}/contract_informations"
    assert_response :success
    assert_equal json_res['data'].length, 10
  end

  test "post create one contract informations and download file" do
    attach = create(:attachment)

    attachment_params = {
        contract_information_type_id: @contract_information_type.id,
        description: Faker::Lorem.sentence,
        attachment_id: attach.id
    }

    assert_difference('ContractInformation.count', 1) do
      post "/profiles/#{@profile.id}/contract_informations", params: attachment_params, as: :json
      the_attach = @profile.contract_informations.last.reload
      assert_equal the_attach.profile, @profile
      assert_equal the_attach.attachment, attach
      assert_equal the_attach.description, attachment_params[:description]
      assert_equal the_attach.contract_information_type, @contract_information_type
      assert_response :ok
    end

    profile_attach = @profile.contract_informations.last
    params = {
        contract_information_id: profile_attach.id
    }

    get "/profiles/#{@profile.id}/contract_informations/#{profile_attach.id}/download", params: params
    assert_equal response.header.fetch('X-Accel-Redirect'), "/internal/#{webmock_seaweed_read_url}/#{fake_seaweed_hash}?#{{filename: 'test.txt'}.to_query}"

    get "/profiles/#{@profile.id}/contract_informations/#{profile_attach.id}/preview"
    assert json_res['state'], "error"
    assert json_res['data'].first.fetch('id'), '422'

    the_attach = profile_attach.attachment
    the_attach.preview_state = 'convert_success'
    the_attach.preview_hash = fake_seaweed_hash
    the_attach.save
    the_attach.reload

    get "/profiles/#{@profile.id}/contract_informations/#{profile_attach.id}/preview"
    assert_equal response.header.fetch('X-Accel-Redirect'), "/internal/#{webmock_seaweed_read_url}/#{fake_seaweed_hash}?"
    assert_response :ok
  end

  test "patch update one contract informations" do
    sample_attach = build(:contract_information)
    sample_attach.creator = @current_user
    sample_attach.contract_information_type = @contract_information_type
    @profile.contract_informations << sample_attach

    another_type = create(:contract_information_type)
    new_description = Faker::Lorem.sentence

    assert_difference('ContractInformation.count', 0) do
      patch "/profiles/#{@profile.id}/contract_informations/#{sample_attach.id}", params: {
          contract_information_type_id: another_type.id,
          description: new_description
      }
      sample_attach.reload
      assert_equal sample_attach.contract_information_type_id, another_type.id
      assert_equal sample_attach.description, new_description
      assert_response :ok
    end
  end

  test "destroy one contract informations" do
    attach = create(:attachment)
    sample_attach = build(:contract_information)
    sample_attach.creator = @current_user
    sample_attach.contract_information_type = @contract_information_type
    sample_attach.attachment = attach
    @profile.contract_informations << sample_attach

    assert_difference('ContractInformation.count', -1) do
      delete "/profiles/#{@profile.id}/contract_informations/#{sample_attach.id}"
    end
    assert_response :ok
  end

end
