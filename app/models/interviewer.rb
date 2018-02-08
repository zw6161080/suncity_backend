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
# Indexes
#
#  index_interviewers_on_applicant_position_id  (applicant_position_id)
#  index_interviewers_on_creator_id             (creator_id)
#  index_interviewers_on_interview_id           (interview_id)
#  index_interviewers_on_user_id                (user_id)
#

class Interviewer < ApplicationRecord
  belongs_to :user
  belongs_to :interview
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to :applicant_position

  enum status: {
    # choose_needed: 1, choose_agreed: 2, choose_refused: 3, 
    interview_needed: 4, interview_agreed: 5, interview_refused: 6,
    interview_completed: 7, interview_cancelled: 8
  }

  scope :waiting_for_choose, -> { where(status: Interviewer.choose_statuses) }
  scope :waiting_for_interview, -> { where(status: Interviewer.interview_statuses) }

  after_update :update_interview_result
  before_create :set_applicant_position_id

  def self.choose_statuses
    [
      Interviewer.statuses[:choose_needed],
      Interviewer.statuses[:choose_agreed],
      Interviewer.statuses[:choose_refused]
    ]
  end

  def self.interview_statuses
    [
      Interviewer.statuses[:interview_needed],
      Interviewer.statuses[:interview_agreed],
      Interviewer.statuses[:interview_refused],
      Interviewer.statuses[:interview_completed],
      Interviewer.statuses[:interview_cancelled]
    ]
  end

  def applicant_profile
    self.applicant_position.try(:applicant_profile)
  end

  def set_applicant_position_id
    self.applicant_position_id = self.interview.applicant_position_id if self.interview
  end

  def update_interview_result
    self.interview.update_result
  end
  
end
