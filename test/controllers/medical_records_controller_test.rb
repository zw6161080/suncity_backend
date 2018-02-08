require 'test_helper'

class MedicalRecordsControllerTest < ActionDispatch::IntegrationTest

  test 'index_by_user' do
    test_user1  = create_test_user
    test_user1.update(grade: 1)
    params = {
      user: test_user1,
      participate: 'participated',
      to_status: nil,
      participate_date: Time.zone.now.to_s.to_date,
      cancel_date: nil,
      valid_date: nil,
      operator_id: test_user1.id,
      medical_template_id: 1
    }
    create(:medical_template, id: 1, chinese_name: 'test', english_name: 'test', simple_chinese_name: 'test', insurance_type: 'suncity_insurance',
           balance_date: Time.zone.now)
    MedicalInsuranceParticipator.create_with_params(params)
    get index_by_user_medical_records_url(user_id: test_user1.id)
    assert_response :ok
    assert_equal json_res['medical_records'].count, 1
    assert_equal json_res['medical_records'].first['creator']['id'], test_user1.id
  end

  def medical_record
    @medical_record ||= medical_records :one
  end

  def test_index
    get medical_records_url
    assert_response :success
  end

  def test_create
    assert_difference('MedicalRecord.count') do
      post medical_records_url, params: { medical_record: {  } }
    end

    assert_response 201
  end

  def test_show
    get medical_record_url(medical_record)
    assert_response :success
  end

  def test_update
    patch medical_record_url(medical_record), params: { medical_record: {  } }
    assert_response 200
  end

  def test_destroy
    assert_difference('MedicalRecord.count', -1) do
      delete medical_record_url(medical_record)
    end

    assert_response 204
  end
end
