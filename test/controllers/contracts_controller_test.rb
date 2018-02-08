require 'test_helper'

class ContractsControllerTest < ActionDispatch::IntegrationTest
  setup do
    position = create(:position_with_full_relations)
    applicant_profile = create_applicant_profile

    @applicant_position = create(:applicant_position)
    @applicant_position.position = position
    @applicant_position.department = position.departments.first
    @applicant_position.applicant_profile = applicant_profile
    @applicant_position.save

    current_user = create(:user)
    ContractsController.any_instance.stubs(:current_user).returns(current_user)
    ContractsController.any_instance.stubs(:authorize).returns(true)
  end

  test "post create one contract and get all contracts list" do
    params = {
      time: Faker::Lorem.sentence,
      comment: Faker::Lorem.sentence,
      status: "cancelled",
      cancel_reason: Faker::Lorem.sentence,
    }

    current_user = create(:user)
    ContractsController.any_instance.stubs(:current_user).returns(current_user)

    assert_difference(['Contract.count', 'ApplicationLog.count'], 1) do
      post "/applicant_positions/#{@applicant_position.id}/contracts", params: params, as: :json
      the_contract = @applicant_position.contracts.last.reload
      assert_equal the_contract.applicant_position, @applicant_position
      assert_equal the_contract.comment, params[:comment]
      assert_equal the_contract.status, params[:status]
      assert_equal the_contract.cancel_reason, params[:cancel_reason]
      assert_response :ok
    end

    get "/applicant_positions/#{@applicant_position.id}/contracts"

    assert_response :ok
  end

  test "patch update one contract" do
    contract = create(:contract)
    @applicant_position.contracts << contract

   params = {
      time: "2016年09月27日 下午02時30分",
      comment: Faker::Lorem.sentence,
      status: "cancelled",
      cancel_reason: Faker::Lorem.sentence,

    }

    current_user = create(:user)
    ContractsController.any_instance.stubs(:current_user).returns(current_user)

    assert_difference('Contract.count', 0) do
    assert_difference('ApplicationLog.count', 1) do
      patch "/applicant_positions/#{@applicant_position.id}/contracts/#{contract.id}", params: params
      contract.reload

      assert_equal contract.time, params[:time]
      assert_equal contract.comment, params[:comment]
      assert_equal contract.status, 'cancelled'
      assert_equal contract.cancel_reason, params[:cancel_reason]

      assert_response :ok
    end
    end
  end

  test 'get contract statuses' do
    get '/contracts/statuses'

    assert_equal json_res['data'], { "modified" => 1, "cancelled" => 2 }
  end

end
