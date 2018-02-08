# == Schema Information
#
# Table name: interviews
#
#  id                    :integer          not null, primary key
#  applicant_position_id :integer
#  time                  :string
#  comment               :text
#  result                :integer          default("needed")
#  score                 :integer          default(0)
#  evaluation            :text
#  need_again            :integer          default(0)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  mark                  :string
#  cancel_reason         :text
#
# Indexes
#
#  index_interviews_on_applicant_position_id  (applicant_position_id)
#

class Interview < ApplicationRecord
  has_many :interviewers
  belongs_to :applicant_position
  has_many :interviewer_users, through: :interviewers, source: :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"

  enum result: {
                  failed: 0,
                  succeed: 1,
                  absent: 2,
                  cancelled: 3,
                  needed: 4,
                  agreed: 5,
                  refused: 6
                }

  after_save :update_interviewers_status


  def send_message_by_result(result, changes, applicant_position, current_user, pre_result)
    LogService.new(:interview_updated, current_user, self, changes).save_log(applicant_position)
    if "cancelled" == result
      Message.add_notification(self, "interview_cancelled", interview_hr_ids) unless interview_hr_ids.empty?
    elsif [:failed, :succeed, :absent].include? self.result.to_sym
      if [:failed, :succeed, :absent].include? pre_result.to_sym
        Message.add_task(self, "interview_updated", interview_hr_ids) unless interview_hr_ids.empty?
      else
        Message.add_task(self, "interview_completed", interview_hr_ids) unless interview_hr_ids.empty?
      end
    else
      Message.add_notification(self, "interview_updated", interview_hr_ids) unless interview_hr_ids.empty?
    end
  end

  def add_interviewers_by_emails(emails, creator_user)
    emails.each do |email|
      self.add_interviewer_by_email(email, creator_user)
    end
  end

  def add_interviewers_by_ids(user_ids, creator_user)
    user_ids.each do |id|
      self.add_interviewer_by_user_id(id, creator_user)
    end
  end


  def remove_interviewers_by_emails(emails)
    emails.each do |email|
      self.remove_interviewer_by_email(email)
    end
  end

  def add_interviewer_by_email(email, creator_user)
    user = User.find_by_email(email)
    if user && self.interviewers.where(user_id: user.id).blank?
      interviewer = Interviewer.new
      interviewer.user = user
      interviewer.creator = creator_user
      interviewer.applicant_position_id = self.applicant_position_id
      interviewer.save
      self.interviewers << interviewer
    end
  end

  def add_interviewer_by_user_id(user_id, creator_user)
    user = User.find(user_id)
    if user && self.interviewers.where(user_id: user.id).blank?
      interviewer = Interviewer.new
      interviewer.user = user
      interviewer.creator = creator_user
      interviewer.applicant_position_id = self.applicant_position_id
      interviewer.save
      self.interviewers << interviewer
    end
  end

  def remove_interviewer_by_email(email)
    user = User.find_by_email(email)
    self.interviewers.find_by_user_id(user.id).destroy if user
  end

  def update_interviewers_status
    self.interviewers.map{ |interviewer| interviewer.interview_cancelled! } if self.result.to_sym == :cancelled
  end

  def update_result
    if [:needed, :agreed, :refused].include?(self.result.to_sym)
      if self.interviewers.pluck(:status).include?('interview_refused')
        self.result = 'refused'
        set_interviewers_status_to_interview_refused
        self.applicant_position.not_accepted!
      elsif self.interviewers.pluck(:status).uniq == ['interview_agreed']
        self.result = 'agreed'
      elsif self.interviewers.pluck(:status).uniq.sort == ['interview_agreed', 'interview_needed'].sort
        self.result = 'needed'
      end
      self.save
    end
  end

  def set_interviewers_status_to_interview_refused
    self.interviewers.each do |interviewer|
      if interviewer.status != 'interview_refused'
        interviewer.status = 'interview_refused'
        interviewer.save
      end
    end
  end

  private
  def interview_hr_ids
    recruit_group_users = Role.find_by(key: 'recruit_group')&.users&.ids
    interviewer_users = self.interviewer_users.pluck(:id)
    (recruit_group_users + interviewer_users).compact.uniq
  end
end
