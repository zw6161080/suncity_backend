# coding: utf-8
# == Schema Information
#
# Table name: profiles
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  region                      :string
#  data                        :jsonb
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  filled_attachment_types     :jsonb
#  attachment_missing_sms_sent :boolean          default(FALSE)
#  is_stashed                  :boolean          default(FALSE)
#  welfare_template_effected   :boolean          default(TRUE)
#  current_template_type       :integer
#  current_welfare_template_id :integer
#  date_of_employment          :string
#

#  id                                    :integer          not null, primary key
#  user_id                               :integer
#  region                                :string
#  data                                  :jsonb
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  filled_attachment_types               :jsonb
#  attachment_missing_sms_sent           :boolean          default(FALSE)
#  is_stashed                            :boolean          default(FALSE)
#  current_template_type                 :integer
#  welfare_template_effected             :boolean          default(TRUE)
#  current_welfare_template_id           :integer
#

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  test 'create a users profile' do
    user = create(:user)
  end

  test 'fork from template' do
    template = Profile.template(region: 'macau').as_json
    filled_template = fill_profile_template(template)
    forked_template = Profile.fork_template(region: 'macau', params: filled_template)

    forked_template.each do |section|
      if section.is_table?
        assert section.attributes.key?('rows')
      else
        assert section.attributes.key?('field_values')
      end
    end

    # save template to user profile
    user = create(:user)
    profile = user.build_profile

    profile_data = forked_template.to_values

    merged_template = Profile.fork_template(region: 'macau', params: profile_data)
    assert merged_template
  end

  test 'profile saving' do
    profile = build(:profile)
    profile.sections = Profile.fork_template(region: 'macau', params:
        fill_profile_template(
            Profile.template(region: 'macau').as_json
        )
    )

    assert profile.save
    career_history = profile.sections.find('career_history')
    assert career_history.attributes.key?('rows')

    new_profile = Profile.find(profile.id)
    career_history = new_profile.sections.find('career_history')
    assert career_history.attributes.key?('rows')
  end

  test 'render json with specify field' do
    #只渲染指定的数据
    profile = create_profile
    fields = ['chinese_name', 'english_name']
    fields_json = profile.as_json_only_fields(fields)
    assert fields_json.key?(fields.first)
    assert fields_json.key?(fields.last)
  end

  # 目前暫時不處理馬尼拉
  # test 'payment_method manila only field' do
  #   section = ProfileSection.find('payment_method')
  #   assert section.belongs_to_region?('manila')
  #   assert_not section.belongs_to_region?('macau')
  # end

  # test 'get manila template' do
  #   template = Profile.template(region: 'manila')
  #
  #   assert template.map(&:key).include?('payment_method')
  #   template = Profile.template(region: 'macau')
  #   assert_not template.map(&:key).include?('payment_method')
  # end

  test 'get career history' do
    profile = create_profile
    assert profile.fetch_career_history_section_rows.is_a?(Array)
  end

  test 'add career history' do
    profile = create_profile
    assert_difference -> { profile.fetch_career_history_section_rows.count }, 1 do
      career_history_params = {
        position_start_date: Date.current,
        position_end_date: Date.current,
        deployment_type: 'xxx',
        trial_period_expiration_date: Date.current,
        salary_calculation: '',
        company_name: '',
        location: '',
        department: '',
        position: '',
        grade: '',
        employment_status: '',
        division_of_job: '',
        deployment_instructions: '',
        comment: '',
      }
      profile.add_career_history_section_row(career_history_params)
    end
  end

  test 'test is_permanent_staff?' do
    profile = create_profile
    assert_equal(
        Config.get(:constants_collection)['FormalEmployeeType'].include?(
            profile.data['position_information']['field_values']['employment_status']
        ),
        profile.is_permanent_staff?
    )
  end

  test 'create_employee_fund_switching_report_item after_create_profile' do
    assert_difference('EmployeeFundSwitchingReportItem.count' , 4) do
      create_profile
    end
  end
end
