# == Schema Information
#
# Table name: interviewers
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  interview_id          :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  status                :integer          default("interview_needed")
#  comment               :text
#  creator_id            :integer
#  applicant_position_id :integer
#

require 'test_helper'

class InterviewerTest < ActiveSupport::TestCase
  test 'interview_statuses' do
    statuses = Interviewer.interview_statuses
    
    assert_equal [4, 5, 6, 7, 8], statuses
  end

end
