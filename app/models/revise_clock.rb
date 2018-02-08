# coding: utf-8
# == Schema Information
#
# Table name: revise_clocks
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
#  record_type :string           default("revise_clock"), not null
#
# Indexes
#
#  index_revise_clocks_on_creator_id  (creator_id)
#  index_revise_clocks_on_user_id     (user_id)
#

class ReviseClock < ApplicationRecord
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :revise_clock_items
  has_many :attend_attachments, as: :attachable
  has_many :attend_approvals, as: :approvable

  enum status: { approved: 1 }

  after_save :modify_attendance_item_and_create_log

  def modify_attendance_item_and_create_log
    att_items = []
    self.revise_clock_items.each do |item|

      attendance_item = AttendanceItem.where(user_id: item.user_id,
                                             attendance_date: item.clock_date).first

      if attendance_item == nil
        # TODO: 這裏需要處理 attendance_item == nil 的情況
        return
      end

      # states
      if item.new_attendance_state != nil
        item.new_attendance_state.each do |state_code_id|
          state = AttendanceState.find(id: state_code_id) rescue nil
          if state != nil
            attendance_item.add_state(state[:chinese_name], 'modify_item')
          end
        end
      end

      att_comment = attendance_item.comment == nil ? '' : attendance_item.comment
      attendance_item.comment = att_comment + item.comment
      attendance_item.start_working_time = item.new_clock_in_time if item.new_clock_in_time
      attendance_item.end_working_time = item.new_clock_out_time if item.new_clock_out_time
      attendance_item.is_modified = true
      attendance_item.save!

      att_items << attendance_item
    end

    att_items.each do |a|
      att_item_log = AttendanceItemLog.new(user_id: a.user_id,
                                           attendance_item_id: a.id,
                                           log_type_id: self.id,
                                           log_type: self.record_type,
                                           log_time: self.date)
      att_item_log.save!
    end
  end
end
