# == Schema Information
#
# Table name: applicant_positions
#
#  id                   :integer          not null, primary key
#  department_id        :integer
#  position_id          :integer
#  applicant_profile_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  order                :string
#  status               :integer          default("not_started")
#  comment              :text
#

require 'test_helper'

class ApplicantPositionTest < ActiveSupport::TestCase
  test "chinese statuses" do
    assert_equal ApplicantPosition.chinese_statuses.keys.sort, ApplicantPosition.statuses.symbolize_keys.keys.sort
  end

  test '待定Position' do
    applicant_profile = create_applicant_profile
    pending_position = applicant_profile.applicant_positions.build(department_id: nil, position_id: nil, order: 1)
    applicant_profile.applicant_positions << pending_position
    assert pending_position.is_pending_position?
  end
end
