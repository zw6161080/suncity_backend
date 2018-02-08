# == Schema Information
#
# Table name: audiences
#
#  id                    :integer          not null, primary key
#  applicant_position_id :integer
#  status                :integer          default("choose_needed")
#  comment               :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :integer
#  time                  :string
#  creator_id            :integer
#
# Indexes
#
#  index_audiences_on_applicant_position_id  (applicant_position_id)
#  index_audiences_on_creator_id             (creator_id)
#  index_audiences_on_user_id                (user_id)
#

class Audience < ApplicationRecord
  belongs_to :applicant_position
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  
  enum status: { choose_needed: 0, agreed: 1, rejected: 2 }
  
  def first_interview
    self.applicant_position.interviews.first if self.applicant_position
  end

  def applicant_profile
    applicant_position.applicant_profile
  end

  def status_chinese_name
    chinese_statuses = { choose_needed: '待篩選', agreed: '同意', rejected: '拒絕' }
    chinese_statuses.fetch(self.status.to_sym, '')
  end

end
