require 'test_helper'

class ContractInformationTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    current_user = create(:user)
  end

  test "get all contract information types list" do
    10.times do
      create(:contract_information_type)
    end

    profile = create_profile
    ContractInformationType.first.contract_informations.new(profile_id: profile.id).save

    get '/contract_information_types'
    assert_response :ok
    assert_equal json_res['data'].count, 10
    assert_equal json_res['data'].first.fetch('can_delete?'), false
  end


  test "post create one contract information type" do
    sample_type = build(:contract_information_type)

    assert_difference('ContractInformationType.count', 1) do
      post '/contract_information_types', params: {
          chinese_name: sample_type.chinese_name,
          english_name: sample_type.english_name,
          description: sample_type.description
      }
      assert_response :ok
    end
  end

  test "get show one contract information type" do
    sample_type = create(:contract_information_type)

    get "/contract_information_types/#{sample_type.id}"
    assert_equal sample_type.id, json_res['data']['id']
    assert_response :ok
  end

  test "patch update one contract information type" do
    sample_type = create(:contract_information_type)
    new_chinese_name = Faker::Lorem.word
    new_english_name = Faker::Lorem.word
    new_description = Faker::Lorem.sentence

    assert_difference('ContractInformationType.count', 0) do
      patch "/contract_information_types/#{sample_type.id}", params: {
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

  test "destroy one contract information type" do
    sample_type = create(:contract_information_type)
    assert_difference('ContractInformationType.count', -1) do
      delete "/contract_information_types/#{sample_type.id}"
    end
    assert_response :ok

    sample_type = create(:contract_information_type)
    profile = create_profile
    profile_attachment = profile.contract_informations.new(profile_id: profile.id)

    sample_type.contract_informations << profile_attachment

    assert_difference('ContractInformationType.count', 0) do
      delete "/contract_information_types/#{sample_type.id}"
    end
  end
end
