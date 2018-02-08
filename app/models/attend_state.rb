# coding: utf-8
# == Schema Information
#
# Table name: attend_states
#
#  id              :integer          not null, primary key
#  attend_id       :integer
#  auto_state      :integer
#  sign_card_state :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  record_type     :integer
#  record_id       :integer
#  remark          :string
#  state           :string
#
# Indexes
#
#  index_attend_states_on_attend_id  (attend_id)
#

class AttendState < ApplicationRecord
  belongs_to :attend

  enum record_type: { sign_card_record: 0, overtime_record: 1, holiday_record: 2, adjust_roster_record: 3, working_hours_transaction_record: 4}

  enum auto_state: { late: 0, leave_early_by_auto: 1, on_work_punching_exception: 2, off_work_punching_exception: 3, punching_card_on_holiday_exception: 4 }
  enum sign_card_state: { forget_to_punch_in: 0, forget_to_punch_out: 1, leave_early: 2, work_out: 3, others: 4, typhoon: 5}

  # enum state: {
  #        overtime: 0,
  #        adjust_roster: 1,
  #        adjust_holiday: 2,
  #        adjust_roster_with_special: 3,
  #        adjust_holiday_with_special: 4,
  #        borrow_hours_as_a: 5,
  #        return_hours_as_a: 6,
  #        borrow_hours_as_b: 7,
  #        return_hours_as_b: 8,
  #        annual_leave: 9,
  #        birthday_leave: 10,
  #        paid_bonus_leave: 11,
  #        compensatory_leave: 12,
  #        paid_sick_leave: 13,
  #        unpaid_sick_leave: 14,
  #        unpaid_leave: 15,
  #        paid_marriage_leave: 16,
  #        unpaid_marriage_leave: 17,
  #        paid_compassionate_leave: 18,
  #        unpaid_compassionate_leave: 19,
  #        maternity_leave: 20,
  #        paid_maternity_leave: 21,
  #        unpaid_maternity_leave: 22,
  #        immediate_leave: 23,
  #        absenteeism: 24,
  #        work_injury: 25,
  #        unpaid_but_maintain_position: 26,
  #        overtime_leave: 27,
  #        pregnant_sick_leave: 28
  #      }

  def self.state_table
    [
      {
        key: 'late',
        chinese_name: '遲到',
        english_name: 'Late',
        simple_chinese_name: '迟到',
      },

      {
        key: 'leave_early_by_auto',
        chinese_name: '早退',
        english_name: 'Leave Early By Auto',
        simple_chinese_name: '早退',
      },

      {
        key: 'on_work_punching_exception',
        chinese_name: '上班打卡異常',
        english_name: 'On Work Punching Exception',
        simple_chinese_name: '上班打卡异常',
      },
      {
        key: 'off_work_punching_exception',
        chinese_name: '下班打卡異常',
        english_name: 'Off Work Punching Exception',
        simple_chinese_name: '下班打卡异常',
      },

      {
        key: 'punching_card_on_holiday_exception',
        chinese_name: '假期打卡異常',
        english_name: 'Punching Card On Holiday Exception',
        simple_chinese_name: '假期打卡异常',
      },

      {
        key: 'forget_to_punch_in',
        chinese_name: '漏打卡上班',
        english_name: 'Forget To Punch In',
        simple_chinese_name: '漏打卡上班',
      },

      {
        key: 'forget_to_punch_out',
        chinese_name: '漏打卡下班',
        english_name: 'Forget To Punch Out',
        simple_chinese_name: '漏打卡下班',
      },

      {
        key: 'leave_early',
        chinese_name: '早退',
        english_name: 'Leave Early',
        simple_chinese_name: '早退',
      },

      {
        key: 'work_out',
        chinese_name: '外出工作',
        english_name: 'Work Out',
        simple_chinese_name: '外出工作',
      },

      {
        key: 'others',
        chinese_name: '其他',
        english_name: 'Others',
        simple_chinese_name: '其他',
      },

      {
        key: 'typhoon',
        chinese_name: '颱風',
        english_name: 'Typhoon',
        simple_chinese_name: '台风',
      },

      {
        key: 'overtime',
        chinese_name: '加班',
        english_name: 'Overtime',
        simple_chinese_name: '加班',
      },

      {
        key: 'adjust_roster',
        chinese_name: '調更',
        english_name: 'Adjust Roster',
        simple_chinese_name: '调更',
      },

      {
        key: 'adjust_holiday',
        chinese_name: '調假',
        english_name: 'Adjust Holiday',
        simple_chinese_name: '调假',
      },

      {
        key: 'adjust_roster_with_special',
        chinese_name: '調更（總監特批）',
        english_name: 'Adjust Roster With Special',
        simple_chinese_name: '调更（总监特批）',
      },

      {
        key: 'adjust_holiday_with_special',
        chinese_name: '調假（總監特批）',
        english_name: 'Adjust Holiday With Special',
        simple_chinese_name: '调假（总监特批）',
      },

      {
        key: 'borrow_hours_as_a',
        chinese_name: '借鐘（甲方）',
        english_name: 'Borrow Hours as A',
        simple_chinese_name: '借钟（甲方）',
      },

      {
        key: 'return_hours_as_a',
        chinese_name: '還鐘（甲方）',
        english_name: 'Return Hours as A',
        simple_chinese_name: '还钟（甲方）',
      },

      {
        key: 'borrow_hours_as_b',
        chinese_name: '借鐘（乙方）',
        english_name: 'Borrow Hours as B',
        simple_chinese_name: '借钟（乙方）',
      },

      {
        key: 'return_hours_as_b',
        chinese_name: '還鐘（乙方）',
        english_name: 'Return Hours as B',
        simple_chinese_name: '还钟（乙方）',
      },
    ] + HolidayRecord.holiday_type_table
  end
end
