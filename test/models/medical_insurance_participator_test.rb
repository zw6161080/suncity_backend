require 'test_helper'

class MedicalInsuranceParticipatorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'create ' do
    test_user = create_test_user
    test_user.update(grade: 1)
    params = {
      user: test_user,
      participate: 'not_participated',
      to_status: nil,
      participate_date: nil,
      cancel_date: Time.zone.now.to_s.to_date,
      valid_date: nil,
      operator_id: test_user.id
    }
    mip  = MedicalInsuranceParticipator.create_with_params(params)
    assert_equal mip.user_id, test_user.id
  end

  test 'create: join' do
    test_user = create_test_user
    test_user.update(grade: 1)
    params = {
      user: test_user,
      participate: 'participated',
      to_status: nil,
      participate_date: Time.zone.now.to_s.to_date,
      cancel_date: nil,
      valid_date: nil,
      medical_template_id: MedicalTemplate.create(chinese_name: 'test', english_name: 'test', simple_chinese_name: 'test',
                                                  insurance_type: 'suncity_insurance', balance_date: Time.zone.now
      ).id,
      operator_id: test_user.id
    }
    mip  = MedicalInsuranceParticipator.create_with_params(params)
    assert_equal mip.user_id, test_user.id
    assert_equal MedicalInsuranceParticipator.count, 1
    assert_equal MedicalRecord.count,  1
    assert MedicalRecord.first.participate
  end
end
