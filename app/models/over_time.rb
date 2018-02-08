# coding: utf-8
# == Schema Information
#
# Table name: over_times
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
#  record_type :string           default("over_time"), not null
#
# Indexes
#
#  index_over_times_on_creator_id  (creator_id)
#  index_over_times_on_user_id     (user_id)
#

class OverTime < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :over_time_items
  has_many :attend_attachments, as: :attachable
  has_many :attend_approvals, as: :approvable

  after_save :modify_attendance_item_and_create_log

  enum status: { approved: 1 }

  def modify_attendance_item_and_create_log
    att_items = []
    self.over_time_items.each do |item|

      attendance_item = AttendanceItem.where(user_id: self.user_id,
                                             attendance_date: item.date).first

      if attendance_item == nil
        # TODO: 這裏需要處理 attendance_item == nil 的情況
        return
      end

      attendance_item.add_state('加班', 'create_record')
      att_comment = attendance_item.comment == nil ? '' : attendance_item.comment.to_s
      attendance_item.comment = att_comment + item.comment.to_s
      overtime_count = attendance_item.overtime_count == nil ? 0 : attendance_item.overtime_count
      begin
        attendance_item.overtime_count = overtime_count.to_i + item.duration.to_i
      rescue
        attendance_item.overtime_count = 0
        Rails.logger.info "overtime_count #{overtime_count} item.duration #{item.duration}"
      end
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
