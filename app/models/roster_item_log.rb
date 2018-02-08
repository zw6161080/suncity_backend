# == Schema Information
#
# Table name: roster_item_logs
#
#  id             :integer          not null, primary key
#  roster_item_id :integer
#  user_id        :integer
#  log_time       :datetime
#  log_type       :string
#  log_type_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_roster_item_logs_on_roster_item_id  (roster_item_id)
#  index_roster_item_logs_on_user_id         (user_id)
#

class RosterItemLog < ApplicationRecord
  belongs_to :roster_item
  belongs_to :user

  validates :roster_item_id, presence: true
  validates :user_id, presence: true
  validates :log_time, presence: true
  validates :log_type, presence: true
  validates :log_type_id, presence: true
end
