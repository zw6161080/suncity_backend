# == Schema Information
#
# Table name: attendance_item_logs
#
#  id                 :integer          not null, primary key
#  attendance_item_id :integer
#  user_id            :integer
#  log_time           :datetime
#  log_type           :string
#  log_type_id        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_attendance_item_logs_on_attendance_item_id  (attendance_item_id)
#  index_attendance_item_logs_on_user_id             (user_id)
#

class AttendanceItemLog < ApplicationRecord
  belongs_to :attendance_item
  belongs_to :user

  validates :attendance_item_id, presence: true
  validates :user_id, presence: true
  validates :log_time, presence: true
  validates :log_type, presence: true
  validates :log_type_id, presence: true
end
