# coding: utf-8
# == Schema Information
#
# Table name: staff_feedbacks
#
#  id                     :integer          not null, primary key
#  feedback_title         :string           not null
#  feedback_content       :text             not null
#  user_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  feedback_date          :datetime
#  feedback_track_status  :string
#  feedback_tracker_id    :integer
#  feedback_track_date    :datetime
#  feedback_track_content :string
#
# Indexes
#
#  index_staff_feedbacks_on_feedback_tracker_id  (feedback_tracker_id)
#  index_staff_feedbacks_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_2617695c8f  (feedback_tracker_id => users.id)
#  fk_rails_5bd135cbee  (user_id => users.id)
#

class StaffFeedback < ApplicationRecord
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :feedback_tracker, :class_name => 'User', :foreign_key => 'feedback_tracker_id'
  has_many :staff_feedback_tracks, dependent: :destroy
  has_many :trackers, through: :staff_feedback_tracks, class_name: 'User', foreign_key: 'tracker_id'

  validates :feedback_date, :feedback_title, :feedback_content, presence: true

  enum feedback_track_status: { untracked: 'staff_feedback.enum_track_status.untracked',
                                tracking:  'staff_feedback.enum_track_status.tracking',
                                tracked:   'staff_feedback.enum_track_status.tracked' }

  def self.detailed_by_id(id)
    StaffFeedback.includes(user: [:department, :position],
                           staff_feedback_tracks: [:tracker]).find(id)
  end

  def self.field_options
    user_query = self.left_outer_joins(user: [:position, :department])
    positions = user_query.select('positions.*').distinct.as_json
    departments = user_query.select('departments.*').distinct.as_json
    return {
        positions: positions,
        departments: departments,
        track_statuses: Config.get('staff_feedbacks').fetch('track_statuses', [])
    }
  end

  def get_json_data
    feedback_data = self.as_json(include: [
        { user: { include: [:department, :position] }},
        :feedback_tracker
    ])
    feedback_data
  end

  # 添加通知。員工提交意見及投訴后，通知員工關係組HR。
  after_create :add_task, :set_default_feedback_track_status
  def add_task
    relation_group_users = Role.find_by(key: 'relation_group')&.users
    feedbacker = User.find(self.user_id)
    Message.add_task(self,
                     'new_feedback',
                     relation_group_users.pluck(:id).uniq,
                     { feedbacker: feedbacker }) unless (relation_group_users.nil? || relation_group_users.empty?)
  end

  def set_default_feedback_track_status
    if self.feedback_track_status.nil?
      self.feedback_track_status = 'staff_feedback.enum_track_status.untracked'
      self.save
    end
  end

  scope :by_users_employee_no, lambda { |empoid|
    where(users: {empoid: empoid})
  }

  scope :by_users_department_id, lambda { |department_id|
    where(users: {department_id: department_id})
  }

  scope :by_users_position_id, lambda { |position_id|
    where(users: {position_id: position_id})
  }

  scope :by_feedback_track_status, lambda { |feedback_track_status|
    where(feedback_track_status: feedback_track_status)
  }

end
