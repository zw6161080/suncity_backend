# coding: utf-8
# == Schema Information
#
# Table name: staff_feedback_tracks
#
#  id                :integer          not null, primary key
#  track_status      :string           default(NULL)
#  track_content     :string
#  staff_feedback_id :integer
#  tracker_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_staff_feedback_tracks_on_staff_feedback_id  (staff_feedback_id)
#  index_staff_feedback_tracks_on_tracker_id         (tracker_id)
#
# Foreign Keys
#
#  fk_rails_45a39996c3  (tracker_id => users.id)
#  fk_rails_6c78a58cbf  (staff_feedback_id => staff_feedbacks.id)
#

class StaffFeedbackTrack < ApplicationRecord
  belongs_to :staff_feedback, class_name: 'staff_feedback', foreign_key: 'staff_feedback_id'
  belongs_to :tracker, class_name: 'User', foreign_key: 'tracker_id'

  enum track_status: { untracked: 'staff_feedback.enum_track_status.untracked',
                       tracking:  'staff_feedback.enum_track_status.tracking',
                       tracked:   'staff_feedback.enum_track_status.tracked' }

  validates :track_status, :track_content, presence: true

  def self.detail_by_id(staff_feedback_id)
    StaffFeedbackTrack
        .includes(:tracker)
        .where(staff_feedback_id: staff_feedback_id)
  end

  # 添加通知。每次HR跟进意见及投诉后，发通知给提交员工。
  after_create :add_notification, :update_feedback_newest_track
  def add_notification
    staff_feedback = StaffFeedback.find(self.staff_feedback_id)
    tracker        = User.find(self.tracker_id)
    # 关于 "标题" 的意见（投诉）有新的跟进，跟进人：""，跟进日期：""
    Message.add_notification(self,
                             'feedback_tracked',
                             staff_feedback.user_id,
                             { feedback: staff_feedback, tracker: tracker })
  end

  def update_feedback_newest_track
    staff_feedback = StaffFeedback.find(self.staff_feedback_id)
    staff_feedback.feedback_track_status  = self.track_status
    staff_feedback.feedback_tracker_id    = self.tracker_id
    staff_feedback.feedback_track_date    = self.created_at
    staff_feedback.feedback_track_content = self.track_content
    staff_feedback.save!
  end
end
