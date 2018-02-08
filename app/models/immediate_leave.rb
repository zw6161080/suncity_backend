# coding: utf-8
# == Schema Information
#
# Table name: immediate_leaves
#
#  id          :integer          not null, primary key
#  date        :date
#  user_id     :integer
#  creator_id  :integer
#  status      :integer          default("approved"), not null
#  item_count  :integer
#  comment     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_type :string           default("immediate_leave"), not null
#
# Indexes
#
#  index_immediate_leaves_on_creator_id  (creator_id)
#  index_immediate_leaves_on_user_id     (user_id)
#

class ImmediateLeave < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :immediate_leave_items
  has_many :attend_attachments, as: :attachable
  has_many :attend_approvals, as: :approvable

  enum status: { approved: 1 }

  after_save :modify_attendance_item_and_create_log

  def modify_attendance_item_and_create_log
    att_items = []
    self.immediate_leave_items.each do |item|

      attendance_item = AttendanceItem.where(user_id: self.user_id,
                                             attendance_date: item.date).first
      if attendance_item == nil
        # TODO: 這裏需要處理 attendance_item == nil 的情況
        return
      end

      attendance_item.add_state('即告', 'create_record')
      att_comment = attendance_item.comment == nil ? '' : attendance_item.comment.to_s
      attendance_item.comment = att_comment + item.comment.to_s
      attendance_item.is_modified = true
      attendance_item.save!

      att_items << attendance_item
    end

    att_items.each do |a|
      att_item_log = AttendanceItemLog.new(user_id: self.user_id,
                                           attendance_item_id: a.id,
                                           log_type_id: self.id,
                                           log_type: self.record_type,
                                           log_time: self.date)
      att_item_log.save!
    end
  end
end
