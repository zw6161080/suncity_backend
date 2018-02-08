# == Schema Information
#
# Table name: annual_bonus_items
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  has_annual_incentive_payment :boolean
#  annual_incentive_payment_hkd :decimal(15, 2)
#  has_double_pay               :boolean
#  double_pay_mop               :decimal(15, 2)
#  has_year_end_bonus           :boolean
#  year_end_bonus_mop           :decimal(15, 2)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  annual_bonus_event_id        :integer
#  career_entry_date            :datetime
#
# Indexes
#
#  index_annual_bonus_items_on_annual_bonus_event_id  (annual_bonus_event_id)
#  index_annual_bonus_items_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_95eea234eb  (user_id => users.id)
#

class AnnualBonusItem < ApplicationRecord
  include StatementAble

  belongs_to :user
  belongs_to :annual_bonus_event

  scope :by_annual_bonus_event_id, -> (event_id) {
    where(annual_bonus_event_id: event_id)
  }

  class << self

    def extra_query_params
      [ { key: 'annual_bonus_event_id' } ]
    end

    def generate(user, annual_bonus_event)
      calc_params = self.create_params - %w(user_id annual_bonus_event_id)
      annual_bonus_event
        .annual_bonus_items
        .where(user: user)
        .first_or_create(user: user)
        .update(calc_params.map {
          |param| [param, self.send("calc_#{param}", user, annual_bonus_event)]
        }.to_h)
    end

    def generate_all(annual_bonus_event)
      # User.salary_calculation_users.each do |user|
      year_month = (annual_bonus_event.salary_settlement? ? annual_bonus_event.settlement_salary_year_month : annual_bonus_event.settlement_date).beginning_of_month
      ProfileService.users4(year_month).find_each(batch_size: 50) do |user|
        generate(user, annual_bonus_event)
      end
    end

    # (未提出离职的)员工在该年度奖金结算时间段内工作的总天数
    def work_days(user, annual_bonus_event)
      work_begin_date = [user.career_entry_date.beginning_of_day, annual_bonus_event.begin_date.beginning_of_day].max
      ((annual_bonus_event.end_date.end_of_day - work_begin_date.beginning_of_day) / 1.day).round
    end

    # 员工是否在年度奖金结算时间段内已经通过试用期
    def is_passed_trial(user, annual_bonus_event)
      # (user.profile.fetch_career_history_section_rows.presence || []).any? do |item|
      CareerRecord.where(user_id: user.id).each do |record|
        begin
          record.career_begin.beginning_of_day <= annual_bonus_event.end_date &&
          Config.get('FormalEmployeeType').include?(record.employment_status)
        rescue
          false
        end
      end
    end

    # 员工在年度奖金结算时间段内是否是兼职
    def is_parttime_employee(user, annual_bonus_event)
      # (user.profile.fetch_career_history_section_rows.presence || []).each do |item|
      CareerRecord.where(user_id: user.id).each do |record|
        begin_date = record.career_begin.beginning_of_day rescue nil
        next if begin_date.nil?
        end_date = record.career_end.presence || annual_bonus_event.end_date.end_of_day
        career_range = (begin_date..end_date)
        if annual_bonus_event.end_date === career_range  &&
          Config.get('ParttimeEmployeeType').include?(record.employment_status)
          return true
        end
      end
      false
    end

    # 员工在年度奖金结算时间段内是否有旷工
    def has_absenteeism(user, annual_bonus_event)
      settle_range = annual_bonus_event.begin_date.beginning_of_day..annual_bonus_event.end_date.end_of_day
      AbsenteeismItem.joins(:absenteeism).where(absenteeisms: { user_id: user.id }).where(date: settle_range).exists?
    end

    # 员工在年度奖金结算时间段内是否有即告
    def has_immediate_leave(user, annual_bonus_event)
      settle_range = annual_bonus_event.begin_date.beginning_of_day..annual_bonus_event.end_date.end_of_day
      ImmediateLeaveItem.joins(:immediate_leave).where(immediate_leaves: { user_id: user.id }).where(date: settle_range).exists?
    end

    # 员工在年度奖金结算时间段内是否有借钟
    def has_borrow_time(user, annual_bonus_event)
      settle_range = annual_bonus_event.begin_date.beginning_of_day..annual_bonus_event.end_date.end_of_day
      BorrowTime
        .where(user_id: user.id)
        .where("to_date(borrow_date, 'YYYY/MM/DD') BETWEEN ? AND ?", settle_range.begin, settle_range.end)
        .exists?
    end

    # 计算员工在年度奖金结算时间段内的迟到或早退次数
    def count_late_or_early_leave(user, annual_bonus_event)
      settle_range = annual_bonus_event.begin_date.beginning_of_day..annual_bonus_event.end_date.end_of_day
      AttendanceItem
        .where(" states LIKE '%遲到%' OR states LIKE '%早退%' ")
        .where(user_id: user.id)
        .where(attendance_date: settle_range)
        .count
    end

    # 员工在年度奖金结算日期前是否申请离职或被解雇
    def has_applied_dimission(user, annual_bonus_event)
      # latest_career = user.profile.fetch_career_history_section_rows.first
      lastest_career = CareerRecord.where(user_id: user.id).order(career_begin: :desc).first
      dimission = Dimission.where(user: user).order(apply_date: :desc).first
      unless dimission.nil? || dimission.apply_date <= latest_career.career_begin
        return false if dimission.apply_date.beginning_of_day <= annual_bonus_event.settlement_date.end_of_day
      end
      true
    end

    # 员工在年度奖金结算时间段内是否有请假
    def has_holiday_or_leave(user, annual_bonus_event)
      settle_range = annual_bonus_event.begin_date.beginning_of_day..annual_bonus_event.end_date.end_of_day
      HolidayItem
        .where(start_time: settle_range)
        .or(HolidayItem.where(end_time: settle_range))
        .or(HolidayItem.where('start_time < :settle_start AND end_time > :settle_end', settle_start: settle_range.begin, settle_end: settle_range.end))
        .joins(:holiday)
        .where(holidays: { user_id: user.id })
        .where(holiday_type: [
          :paid_illness_leave,
          :none_paid_leave,
          :paid_marriage_holiday,
          :nonepaid_marriage_holiday,
          :nonepaid_grace_leave,
          :awaiting_delivery_leave,
          :paid_maternity_leave,
          :nonepaid_maternity_leave,
          :without_pay_stay_leave,
          :pregnancy_leave,
          :best_employee_holiday,
          :other_leave
        ]).exists?
    end

    # 年度奖金时间段总天数
    def total_days(annual_bonus_event)
      ((annual_bonus_event.end_date.end_of_day - annual_bonus_event.begin_date.beginning_of_day) / 1.day).round
    end

    def calc_has_annual_incentive_payment(user, annual_bonus_event)
      # 奖金不适用于兼职员工
      return false if is_parttime_employee(user, annual_bonus_event)

      # 工作满90天
      return false unless work_days(user, annual_bonus_event) >= 90

      # 并且通过试用期
      return false unless is_passed_trial(user, annual_bonus_event)

      # 没有任何请假及缺勤记录（年假、生日假、有新奖励假、补假、有薪恩恤假除外）
      return false if has_holiday_or_leave(user, annual_bonus_event)

      # 旷工
      return false if has_absenteeism(user, annual_bonus_event)

      # 即告
      return false if has_immediate_leave(user, annual_bonus_event)

      # 没有任何借钟记录
      return false if has_borrow_time(user, annual_bonus_event)

      # 没有任何迟到早退记录
      return false if count_late_or_early_leave(user, annual_bonus_event) > 0

      # 若员工于发放当日或之前，已提交离职通知或被公司解雇，将不符合录取奖金资格
      # 在发放当日或之前，未提交过离职通知或被公司解雇
      return false if has_applied_dimission(user, annual_bonus_event)

      true
    end

    def calc_annual_incentive_payment_hkd(user, annual_bonus_event)
      settle_range = annual_bonus_event.begin_date.beginning_of_day..annual_bonus_event.end_date.end_of_day

      # 工伤不超过30天者，可获全数之全年勤工奖奖金；
      work_injury_leaves = HolidayItem
                             .where(start_time: settle_range)
                             .joins(:holiday)
                             .or(HolidayItem
                                   .where(end_time: settle_range)
                                   .joins(:holiday))
                             .or(HolidayItem
                                   .where('start_time < :settle_start AND end_time > :settle_end',
                                          settle_start: settle_range.begin,
                                          settle_end: settle_range.end)
                                   .joins(:holiday))
                             .where(holidays: { user_id: user.id })
                             .where(holiday_type: :work_injury_leave)

      work_injury_days = work_injury_leaves.inject(0) do |sum, item|
        sum + (item.end_time - item.start_time).to_i + 1
      end

      # 若工伤超过30天，则全年勤工奖超过30天，则全年勤工奖按缺勤天数按比例扣减（前30天不计算在内）
      percent = BigDecimal('1.0') - BigDecimal([work_injury_days - 30, 0].max) / BigDecimal(total_days(annual_bonus_event))

      annual_bonus_event.annual_incentive_payment_hkd * percent
    end

    def calc_has_double_pay(user, annual_bonus_event)
      # user.profile.sections.find('holiday_information').field_value('double_pay')
      ActiveModelSerializers::SerializableResource.new(WelfareRecord.where(user: user.id).where('welfare_begin <= :date AND welfare_end >= :date', date: annual_bonus_event.settlement_date).first).serializer_instance.try(:double_pay) rescue false
    end

    def calc_double_pay_mop(user, annual_bonus_event)
      # if user.profile.sections.find('holiday_information').field_value('double_pay')
      if calc_has_double_pay(user, annual_bonus_event)
        # 遍历薪酬历史，按照薪酬时间比例计算
        # (user.profile.fetch_salary_history_section_rows.presence || []).inject(BigDecimal('0.0')) do |sum, item|
        SalaryRecord.where(user_id: user.id).inject(BigDecimal('0.0')) do |sum, record|
          # 计算全年奖金的时间段
          date_range = annual_bonus_event.begin_date..annual_bonus_event.end_date

          # 薪酬的时间段
          salary_start_date = record.salary_begin
          salary_end_date = record.salary_end

          # 如果在范围内
          if salary_start_date === date_range || salary_end_date === date_range
            start_date = [annual_bonus_event.begin_date, salary_start_date].max
            end_date = [annual_bonus_event.end_date, salary_end_date].min
            # 薪酬历史在全年奖金里的时间段
            ss = ActiveModelSerializers::SerializableResource.new(salary_record).serializer_instance
            # TODO(zhangmeng): 需要确认一下这里是否会存在负值
            salary_days = (end_date.end_of_day - start_date.beginning_of_day) / 1.day
            salary_days = BigDecimal(salary_days.round)
            total_amount = BigDecimal(ss.try(:final_basic_salary) || 0) + BigDecimal(ss.try(:final_bonus) || 0) + BigDecimal(ss.try(:final_attendance_award) || 0)
            # 按在职天数比例计算
            sum + salary_days / BigDecimal(total_days(annual_bonus_event)) * total_amount
          else
            sum
          end
        end
      else
        BigDecimal.new('0.0')
      end
    end

    def calc_has_year_end_bonus(user, annual_bonus_event)
      # 工作满90天
      return false if work_days(user, annual_bonus_event) < 90

      # 并且通过试用期
      return false unless is_passed_trial(user, annual_bonus_event)

      # 在发放当日或之前，未提交过离职通知或被公司解雇
      return false if has_applied_dimission(user, annual_bonus_event)

      true
    end

    def calc_year_end_bonus_mop(user, annual_bonus_event)
      # 以结算日期最后一个月的底薪为基准
      # salary_item = (user.profile.fetch_salary_history_section_rows.presence || []).find do |item|
      salary_item = SalaryRecord.where(user_id: user.id).find do |record|
        begin_date = record.salary_begin
        end_date = record.salary_end

        if begin_date.nil? && end_date.nil?
          false
        elsif end_date.nil? && !begin_date.nil?
          return (begin_date <= annual_bonus_event.end_date.end_of_day rescue false)
        elsif !begin_date.nil? && !end_date.nil?
          date_range = (begin_date..end_date)
          return annual_bonus_event.end_date === date_range
        else
          false
        end
      end

      ss = ActiveModelSerializers::SerializableResource.new(salary_item).serializer_instance
      salary_amount = salary_item.nil? ? BigDecimal('0') : BigDecimal(salary_item.final_basic_salary)

      # 如果是设定了按照固定金额，就取设定的固定金额，否则取底薪
      base_amount = annual_bonus_event.by_salary? ? salary_amount : annual_bonus_event.year_end_bonus_mop

      # 在职天数
      total_work_days = BigDecimal(work_days(user, annual_bonus_event))

      bonus_mop = base_amount * total_work_days / BigDecimal(total_days(annual_bonus_event))
      percent = BigDecimal('1.0')

      settle_range = annual_bonus_event.begin_date.beginning_of_day..annual_bonus_event.end_date.end_of_day

      # 如果有旷工，扣5%
      if has_absenteeism(user, annual_bonus_event)
        percent = [BigDecimal(0), percent - SalaryCalculationService.salary_element_setting('year_end_bonus_absenteeism_reduction_percent') / BigDecimal('100')].max
      end

      # 如果有即告，扣5%
      if has_immediate_leave(user, annual_bonus_event)
        percent = [BigDecimal(0), percent - SalaryCalculationService.salary_element_setting('year_end_bonus_immediate_leave_reduction_percent') / BigDecimal('100')].max
      end

      # 如果迟到5此及以上，扣5%
      if count_late_or_early_leave(user, annual_bonus_event) >= 5
        percent = [BigDecimal(0), percent - SalaryCalculationService.salary_element_setting('year_end_bonus_late_more_than_5_times_reduction_percent') / BigDecimal('100')].max
      end

      # 如果有警告信，扣50%, 如果有两份扣100%
      punishment_count = Punishment
                           .where(punishment_date: settle_range)
                           .or(Punishment.where(profile_abolition_date: settle_range))
                           .or(Punishment.where('punishment_date < :settle_begin_date AND profile_abolition_date > :settle_end_date',
                                                settle_begin_date: settle_range.begin,
                                                settle_end_date: settle_range.end))
                           .where(user_id: user.id)
                           .where(punishment_result: [:classA_written_warning, :classB_written_warning, :final_written_warning ])
                           .count
      if punishment_count == 1
        percent = [BigDecimal(0), percent - SalaryCalculationService.salary_element_setting('year_end_bonus_one_punishment_reduction_percent') / BigDecimal('100')].max
      end

      if punishment_count > 1
        percent = [BigDecimal('0.0'), percent - SalaryCalculationService.salary_element_setting('year_end_bonus_two_or_more_punishments_reduction_percent') / BigDecimal('100')].max
      end

      bonus_mop * percent
    end

    def calc_career_entry_date(user, annual_bonus_event)
      user.career_entry_date
    end
  end
end
