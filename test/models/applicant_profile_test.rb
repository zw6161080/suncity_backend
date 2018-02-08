# == Schema Information
#
# Table name: applicant_profiles
#
#  id             :integer          not null, primary key
#  applicant_no   :string
#  chinese_name   :string
#  english_name   :string
#  id_card_number :string
#  region         :string
#  data           :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  source         :string
#  profile_id     :integer
#  get_info_from  :jsonb
#

require 'test_helper'

class ApplicantProfileTest < ActiveSupport::TestCase
  test '获取求职者资料模版' do
    template = ApplicantProfile.template(region: 'macau')
    assert template
    template = ApplicantProfile.template(region: 'manila')
    assert template
  end

  test '创建求职者资料' do
    applicant_profile = create_applicant_profile
    assert_equal 3, applicant_profile.applicant_positions.count

    applicant_profile.save
    assert_equal 3, applicant_profile.applicant_positions.count
  end

  test '求职者编号生成' do
    today_time_prefix = Time.now.strftime("%y%m%d")
    no = ApplicantProfile.get_applicant_no
    profile1 = create_applicant_profile
    assert_equal no, profile1.applicant_no
    no2 = ApplicantProfile.get_applicant_no
    assert_not no == no2
    profile2 = create_applicant_profile
    profile3 = create_applicant_profile
    assert_not profile2.applicant_no == profile3.applicant_no
    assert_equal profile1.applicant_no, "R-#{today_time_prefix}0001"
    assert_equal profile2.applicant_no, "R-#{today_time_prefix}0002"
    assert_equal profile3.applicant_no, "R-#{today_time_prefix}0003"
  end

  test '创建完档案之后 新加入模版 修改测试' do
    profile = create_applicant_profile
    data = profile.data
    data['language_and_skill']['field_values'] = nil
    profile.update_column(:data, data)

    profile.reload
    assert_nil profile.data['language_and_skill']['field_values']

    profile.edit_field({section_key: 'language_and_skill', field: 'language_chinese', new_value: 'good'}.with_indifferent_access)
  end

  test 'attachment_types_map' do
    type1 = create(:profile_attachment_type, chinese_name: 'AA', english_name: 'aa')
    type2 = create(:profile_attachment_type, chinese_name: 'BB', english_name: 'bb')
    type3 = create(:profile_attachment_type, chinese_name: 'CC', english_name: 'cc')
    type4 = create(:profile_attachment_type, chinese_name: 'DD', english_name: 'dd')

    type5 = create(:applicant_attachment_type, chinese_name: 'BB', english_name: 'bb')
    type6 = create(:applicant_attachment_type, chinese_name: 'CC', english_name: 'cc')
    type7 = create(:applicant_attachment_type, chinese_name: 'DD', english_name: 'dd')
    type8 = create(:applicant_attachment_type, chinese_name: 'EE', english_name: 'ee')

    assert_equal ApplicantProfile.attachment_types_map(type5.id), type2.id
    assert_equal ApplicantProfile.attachment_types_map(type6.id), type3.id
    assert_equal ApplicantProfile.attachment_types_map(type7.id), type4.id
  end
end
