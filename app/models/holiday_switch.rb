# coding: utf-8
# == Schema Information
#
# Table name: holiday_switches
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  user_b_id   :integer
#  creator_id  :integer
#  status      :integer          default("approved"), not null
#  comment     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_type :string           default("holiday_switch"), not null
#
# Indexes
#
#  index_holiday_switches_on_creator_id  (creator_id)
#  index_holiday_switches_on_user_b_id   (user_b_id)
#  index_holiday_switches_on_user_id     (user_id)
#

class HolidaySwitch < ApplicationRecord
  belongs_to :user
  belongs_to :user_b , :class_name => "User", :foreign_key => "user_b_id"
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :holiday_switch_items
  has_many :attend_attachments, as: :attachable
  has_many :attend_approvals, as: :approvable

  enum status: { approved: 1 }

  after_save :modify_roster_item_and_create_log

  def modify_roster_item_and_create_log
    roster_items = []
    self.holiday_switch_items.each do |item|

      roster_item_a = RosterItem.where(user_id: item.user_id,
                                       date: item.a_date).first

      roster_item_b = RosterItem.where(user_id: item.user_b_id,
                                       date: item.b_date).first

      if roster_item_a == nil || roster_item_b == nil
        # TODO(zhangmeng): 需要处理 roster_item_a == nil 或者 roster_item_b == nil 的情况
        return
      end

      shift_a = roster_item_a.try(:shift)
      shift_b = roster_item_b.try(:shift)

      roster_item_a.shift = shift_b
      roster_item_b.shift = shift_a

      roster_item_a.date, roster_item_b.date = roster_item_b.date, roster_item_a.date
      roster_item_a.leave_type, roster_item_b.leave_type = roster_item_b.leave_type, roster_item_a.leave_type
      roster_item_a.start_time, roster_item_b.start_time = roster_item_b.start_time, roster_item_a.start_time
      roster_item_a.end_time, roster_item_b.end_time = roster_item_b.end_time, roster_item_a.end_time
      roster_item_a.state, roster_item_b.state = roster_item_b.state, roster_item_a.state

      roster_item_a.is_modified = true
      roster_item_b.is_modified = true

      roster_item_a.save!
      roster_item_b.save!

      roster_items << roster_item_a << roster_item_b
    end

    roster_items.each do |item|
      roster_item_log = RosterItemLog.new(user_id: self.user_id,
                                          roster_item_id: item.id,
                                          log_type_id: self.id,
                                          log_type: self.record_type,
                                          log_time: self.created_at)
      roster_item_log.save!
    end
  end

end
