# == Schema Information
#
# Table name: attend_month_approvals
#
#  id                        :integer          not null, primary key
#  status                    :integer
#  employee_counts           :integer
#  roster_counts             :integer
#  general_holiday_counts    :integer
#  punching_counts           :integer
#  punching_exception_counts :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  month                     :string
#  is_settlement             :boolean
#  approval_time             :datetime
#  calc_state                :integer
#

class AttendMonthApproval < ApplicationRecord
  enum status: { approval: 0, not_approval: 1 }

  enum calc_state: { not_calc: 0, calculating: 1, calculated: 2 }

  scope :by_employee_counts, lambda { |counts|
    where(employee_counts: counts) if counts
  }

  scope :by_roster_counts, lambda { |counts|
    where(roster_counts: counts) if counts
  }

  scope :by_general_holiday_counts, lambda { |counts|
    where(general_holiday_counts: counts) if counts
  }

  scope :by_punching_counts, lambda { |counts|
    where(punching_counts: counts) if counts
  }

  scope :by_punching_exception_counts, lambda { |counts|
    where(punching_exception_counts: counts) if counts
  }

  scope :by_status, lambda { |status|
    where(status: status) if status
  }

  scope :by_month, lambda { |month|
    where(month: month) if month
  }

  after_commit :update_attend_approval_info, on: :create

  # after_commit :calc_compensate_reports, on: :update

  # after_commit :update_compensate_reports, on: :cancel_approval

  def e_counts
    Rails.cache.fetch("#{cache_key}/e_counts", expires_in: 12.hours) do
      User.all.count
    end
  end

  def r_counts(start_date, end_date)
    Rails.cache.fetch("#{cache_key}/r_counts", expires_in: 12.hours) do
      # rl_ids = RosterList.where("status = ? OR status = ?", 1, 2).pluck(:id) # public and sealed
      # real_roster_objects = RosterObject.where(roster_list_id: rl_ids, is_active: ['active', nil])

      rls = RosterList.where("status = ? OR status = ?", 1, 2) # public and sealed

      r_ids = rls.inject([]) do |sum, list|
        list_ros = RosterObject.where(location_id: list.location_id, department_id: list.department_id, is_active: ['active', nil])
                     .where("roster_date >= ? AND roster_date <= ?", list.start_date, list.end_date)
        true_ro_ids = []
        list_ros.each do |t_ro|
          if t_ro && t_ro.roster_date && t_ro.user_id
            d = t_ro.roster_date
            date_of_employment = t_ro&.user&.profile&.data['position_information']['field_values']['date_of_employment']
            entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

            position_resigned_date = t_ro&.user&.profile&.data['position_information']['field_values']['resigned_date']
            leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

            is_entry = (entry && (d >= entry))
            not_leave = (leave == nil || (d <= leave))
            true_ro_ids << t_ro.id if (is_entry && not_leave)
          end
        end

        sum = sum + true_ro_ids
        sum
      end.compact.uniq

      real_roster_objects = RosterObject.where(id: r_ids)
      r_objects = real_roster_objects.where(roster_date: start_date..end_date, is_general_holiday: [false, nil], holiday_type: nil)
      cs_count = r_objects.where(working_time: nil).where.not(class_setting_id: nil).count
      wk_count = r_objects.where(class_setting_id: nil).where.not(working_time: nil).count
      cs_count + wk_count
    end
  end

  def gh_counts(start_date, end_date)
    Rails.cache.fetch("#{cache_key}/gh_counts", expires_in: 12.hours) do
      # rl_ids = RosterList.where("status = ? OR status = ?", 1, 2).pluck(:id)
      # real_roster_objects = RosterObject.where(roster_list_id: rl_ids, is_active: ['active', nil])

      rls = RosterList.where("status = ? OR status = ?", 1, 2) # public and sealed

      r_ids = rls.inject([]) do |sum, list|
        list_ros = RosterObject.where(location_id: list.location_id, department_id: list.department_id, is_active: ['active', nil])
                     .where("roster_date >= ? AND roster_date <= ?", list.start_date, list.end_date)

        true_ro_ids = []
        list_ros.each do |t_ro|
          if t_ro && t_ro.roster_date && t_ro.user_id
            d = t_ro.roster_date
            date_of_employment = t_ro&.user&.profile&.data['position_information']['field_values']['date_of_employment']
            entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

            position_resigned_date = t_ro&.user&.profile&.data['position_information']['field_values']['resigned_date']
            leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

            is_entry = (entry && (d >= entry))
            not_leave = (leave == nil || (d <= leave))
            true_ro_ids << t_ro.id if (is_entry && not_leave)
          end
        end

        sum = sum + true_ro_ids
        sum
      end.compact.uniq

      real_roster_objects = RosterObject.where(id: r_ids)

      real_roster_objects.where(roster_date: start_date..end_date, is_general_holiday: true, holiday_type: nil).count
    end
  end

  def p_counts(start_date, end_date)
    Rails.cache.fetch("#{cache_key}/p_counts", expires_in: 12.hours) do
      attends = Attend.where(attend_date: start_date..end_date)
      punching_count = attends.inject(0) do |sum, att|
        if att && att.user_id
          on_signcard_records = SignCardRecord.where(user_id: att.user_id,
                                                     source_id: nil,
                                                     is_get_to_work: true,
                                                     is_deleted: [false, nil],
                                                     sign_card_date: att.attend_date.to_date)

          off_signcard_records = SignCardRecord.where(user_id: att.user_id,
                                                      source_id: nil,
                                                      is_get_to_work: false,
                                                      is_deleted: [false, nil],
                                                      sign_card_date: att.attend_date.to_date)

          on_work_punch_count = (on_signcard_records.count > 0 || att.on_work_time != nil) ? 1 : 0
          off_work_punch_count = (off_signcard_records.count > 0 || att.off_work_time != nil) ? 1 : 0

          sum += (on_work_punch_count + off_work_punch_count)
        else
          sum
        end
      end

      punching_count
    end
  end

  def pe_counts(start_date, end_date)
    Rails.cache.fetch("#{cache_key}/pe_counts", expires_in: 12.hours) do
      attends = Attend.where(attend_date: start_date..end_date)

      exception_count = attends.inject(0) do |sum, att|
        if att.user_id
          on_signcard_records = SignCardRecord.where(user_id: att.user_id,
                                                     source_id: nil,
                                                     is_get_to_work: true,
                                                     is_deleted: [false, nil],
                                                     sign_card_date: att.attend_date.to_date)

          off_signcard_records = SignCardRecord.where(user_id: att.user_id,
                                                      source_id: nil,
                                                      is_get_to_work: false,
                                                      is_deleted: [false, nil],
                                                      sign_card_date: att.attend_date.to_date)

          hr = HolidayRecord.where(user_id: att.user_id, source_id: nil, is_deleted: [false, nil])
                 .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)

          d = att.attend_date
          date_of_employment = att&.user&.profile&.data['position_information']['field_values']['date_of_employment']
          entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

          position_resigned_date = att&.user&.profile&.data['position_information']['field_values']['resigned_date']
          leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

          is_entry = (entry && (d >= entry))
          not_leave = (leave == nil || (d <= leave))

          on_judge = (on_signcard_records.count <= 0 && hr.count <= 0)
          off_judge = (off_signcard_records.count <= 0 && hr.count <= 0)

          late = is_entry && not_leave && on_judge && att.attend_states.where(auto_state: 'late').count > 0 ? 1 : 0
          leave_early = is_entry && not_leave && off_judge && att.attend_states.where(auto_state: 'leave_early_by_auto').count > 0 ? 1 : 0
          on_exception = is_entry && not_leave && on_judge && att.attend_states.where(auto_state: 'on_work_punching_exception').count > 0 ? 1 : 0
          off_exception = is_entry && not_leave && off_judge && att.attend_states.where(auto_state: 'off_work_punching_exception').count > 0 ? 1 : 0
          punch_card_on_holiday_exception = is_entry && not_leave && att.attend_states.where(auto_state: 'punching_card_on_holiday_exception').count > 0 ? 2 : 0
          sum += (late + leave_early + on_exception + off_exception + punch_card_on_holiday_exception)
        else
          sum
        end
      end
      exception_count
    end
  end

  def is_settlement_value(month)
    y, m = month.split('/').map(& :to_i)
    start_date = Time.zone.local(y, m, 1).to_datetime.beginning_of_month - 2.day
    end_date = Time.zone.local(y, m, 1).to_datetime.end_of_month - 2.day
    r = MonthSalaryReport.where(year_month: start_date..end_date, status: 'president_examine').count
    is_settlement = r > 0 ? true : false
    is_settlement
  end

  def set_data
    month = self.month
    year, month = month.split('/').map(& :to_i)
    if year > 0 && (month > 0 && month <= 12)
      t = Time.zone.local(year, month, 1).to_date
      start_date = t.beginning_of_month
      end_date = t.end_of_month

      self.employee_counts = e_counts

      self.roster_counts = r_counts(start_date, end_date)
      self.general_holiday_counts = gh_counts(start_date, end_date)

      self.punching_counts = p_counts(start_date, end_date)

      self.punching_exception_counts = pe_counts(start_date, end_date)
      self.is_settlement = is_settlement_value(self.month)
      self.save!
    end
  end

  def self.update_data(date)
    m_str = date.strftime("%Y/%m")
    ama = AttendMonthApproval.where(month: m_str).first
    if ama
      UpdateAttendMonthApprovalJob.perform_later(ama)
    end
  end

  private

  def update_attend_approval_info
    UpdateAttendMonthApprovalJob.perform_later(self)
  end

  # def calc_compensate_reports
  #   # month fmt: '2017/01'
  #   month = self.month
  #   year, month = month.split('/').map(& :to_i)
  #   CalcCompensateReportJob.perform_later(year, month)
  # end

  # def update_compensate_reports
  #   CompensateReport.update_reports_after_cancel_approval(self)
  # end
end
