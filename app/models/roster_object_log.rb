# coding: utf-8
# == Schema Information
#
# Table name: roster_object_logs
#
#  id                                  :integer          not null, primary key
#  approver_id                         :integer
#  approval_time                       :datetime
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  roster_object_id                    :integer
#  class_setting_id                    :integer
#  is_general_holiday                  :boolean
#  working_time                        :string
#  modified_reason                     :string
#  holiday_type                        :string
#  borrow_return_type                  :string
#  working_hours_transaction_record_id :integer
#
# Indexes
#
#  index_roster_object_logs_on_approver_id                          (approver_id)
#  index_roster_object_logs_on_class_setting_id                     (class_setting_id)
#  index_roster_object_logs_on_roster_object_id                     (roster_object_id)
#  index_roster_object_logs_on_working_hours_transaction_record_id  (working_hours_transaction_record_id)
#

class RosterObjectLog < ApplicationRecord
  belongs_to :roster_object
  belongs_to :approver, :class_name => "User", :foreign_key => "approver_id"
  belongs_to :class_setting

  belongs_to :working_hours_transaction_record

  def self.modified_reason_table
    [
      {
        key: 'transfer_location',
        chinese_name: '調館',
        english_name: 'Transfer Location',
        simple_chinese_name: '调馆'
      },
      {
        key: 'lent_temporarily',
        chinese_name: '暫借',
        english_name: 'Lent Temporarily',
        simple_chinese_name: '暂借'
      },
      {
        key: 'transfer_position',
        chinese_name: '調職',
        english_name: 'Transfer Position',
        simple_chinese_name: '调职'
      },
      {
        key: 'special_roster',
        chinese_name: '特别排班',
        english_name: 'Special Roster',
        simple_chinese_name: '特别排班'
      },
      {
        key: 'modify_roster',
        chinese_name: '修改排班',
        english_name: 'Modify Roster',
        simple_chinese_name: '修改排班'
      },
      {
        key: 'dont_calc_holiday',
        chinese_name: '不計算假期',
        english_name: 'Dont Calc Holiday',
        simple_chinese_name: '不计算假期'
      },

      {
        key: 'add_borrow_as_a',
        chinese_name: '借鐘（甲方）',
        english_name: 'Borrow As A',
        simple_chinese_name: '借钟（甲方）'
      },
      {
        key: 'add_borrow_as_b',
        chinese_name: '借鐘（乙方）',
        english_name: 'Borrow As B',
        simple_chinese_name: '借钟（乙方）'
      },
      {
        key: 'cancel_borrow_as_a',
        chinese_name: '取消借鐘（甲方）',
        english_name: 'Cancel Borrow As A',
        simple_chinese_name: '取消借钟（甲方）'
      },
      {
        key: 'cancel_borrow_as_b',
        chinese_name: '取消借鐘（乙方）',
        english_name: 'Cancel Borrow As B',
        simple_chinese_name: '取消借钟（乙方）'
      },

      {
        key: 'add_return_as_a',
        chinese_name: '還鐘（甲方）',
        english_name: 'Return As A',
        simple_chinese_name: '还钟（甲方）'
      },
      {
        key: 'add_return_as_b',
        chinese_name: '還鐘（乙方）',
        english_name: 'Return As B',
        simple_chinese_name: '还钟（乙方）'
      },
      {
        key: 'cancel_return_as_a',
        chinese_name: '取消還鐘（甲方）',
        english_name: 'Cancel Return As A',
        simple_chinese_name: '取消还钟（甲方）'
      },
      {
        key: 'cancel_return_as_b',
        chinese_name: '取消還鐘（乙方）',
        english_name: 'Cancel Return As B',
        simple_chinese_name: '取消还钟（乙方）'
      },

      {
        key: 'adjust_for_class',
        chinese_name: '調更',
        english_name: 'Adjust For Class',
        simple_chinese_name: '调更'
      },
      {
        key: 'adjust_for_holiday',
        chinese_name: '調假',
        english_name: 'Adjust For Holiday',
        simple_chinese_name: '调假'
      },
      {
        key: 'cancel_adjust_for_class',
        chinese_name: '取消調更',
        english_name: 'Cancel Adjust For Class',
        simple_chinese_name: '取消调更'
      },
      {
        key: 'cancel_adjust_for_holiday',
        chinese_name: '取消調假',
        english_name: 'Cancel Adjust For Holiday',
        simple_chinese_name: '取消调假'
      },
    ]
  end
end
