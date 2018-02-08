# == Schema Information
#
# Table name: attend_logs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  attend_id  :integer
#  logger_id  :integer
#  apply_type :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type_id    :integer
#
# Indexes
#
#  index_attend_logs_on_attend_id  (attend_id)
#  index_attend_logs_on_logger_id  (logger_id)
#

class AttendLog < ApplicationRecord
  belongs_to :log_user, class_name: "User", foreign_key: "logger_id"
  belongs_to :attend

  enum apply_type: { sign_card: 0, overtime: 1, holiday: 2,
                     adjust_roster: 3, working_hours_transaction: 4 }
end
