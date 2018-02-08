# == Schema Information
#
# Table name: annual_award_reports
#
#  id                               :integer          not null, primary key
#  year_month                       :datetime
#  annual_attendance_award_hkd      :decimal(15, 2)
#  annual_bonus_grant_type          :string
#  grant_type_rule                  :jsonb
#  absence_deducting                :decimal(15, 2)
#  notice_deducting                 :decimal(15, 2)
#  late_5_times_deducting           :decimal(15, 2)
#  sign_card_deducting              :decimal(15, 2)
#  one_letter_of_warning_deducting  :decimal(15, 2)
#  two_letters_of_warning_deducting :decimal(15, 2)
#  each_piece_of_awarding_deducting :decimal(15, 2)
#  method_of_settling_accounts      :string
#  award_date                       :datetime
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  status                           :string
#

class AnnualAwardReport < ApplicationRecord
  include AnnualAwardReportValidators
  validates :annual_bonus_grant_type, inclusion: {in: %w(all division_of_job departments)}
  validates :year_month, :annual_attendance_award_hkd, :absence_deducting, :notice_deducting, :late_5_times_deducting,
            :sign_card_deducting, :one_letter_of_warning_deducting, :each_piece_of_awarding_deducting, :award_date, :grant_type_rule, presence: true
  validates :method_of_settling_accounts, inclusion: {in: %w(wage single-handed)}
  validates :status, inclusion: {in: %w(not_granted has_granted fail calculating)}, unless: :status_is_nil?
  validates_with GrantTypeRuleValidator
  validates :year_month, uniqueness: true
  has_many :grant_type_details, dependent: :destroy
  has_many :annual_award_report_items, dependent: :destroy

  def grant
    ActiveRecord::Base.transaction do
      if self.method_of_settling_accounts == 'single-handed'
        self.annual_award_report_items.each do |item|
          user = item.user
          amount_in_mop = if user.company_name == 'suncity_group_commercial_consulting'
                            SalaryCalculationService.hkd_to_mop(
                              (item.double_pay_final_hkd || BigDecimal(0)) + (item.annual_at_duty_final_hkd || BigDecimal(0)) + (item.end_bonus_final_hkd || BigDecimal(0))
                            )
                          else
                            SalaryCalculationService.hkd_to_mop(
                              (item.double_pay_final_hkd || BigDecimal(0))
                            )
                          end
          amount_in_hkd = if user.company_name == 'suncity_group_commercial_consulting'
                            BigDecimal(0)
                          else
                            ((item.annual_at_duty_final_hkd || BigDecimal(0)) + (item.end_bonus_final_hkd || BigDecimal(0)))
                          end
          if self.method_of_settling_accounts == 'single-handed'
            BankAutoPayReportItem.create(
              record_type: :annual_reward,
              year_month: self.award_date.beginning_of_month,
              balance_date: self.award_date, user_id: item.user_id,
              amount_in_mop: amount_in_mop, amount_in_hkd: amount_in_hkd,
              cash_or_check: ProfileService.payment_method(item.user),
              begin_work_date: self.award_date,
              end_work_date: self.award_date,
              leave_in_this_month: nil,
              company_name: user.company_name,
              department_id: item.department_id,
              position_id: item.position_id,
              position_of_govt_record: ProfileService.position_of_govt_record(user),
              id_number: user.profile.data['personal_information']['field_values']['id_number'],
              bank_of_china_account_mop: user.profile.data['personal_information']['field_values']['bank_of_china_account_mop'],
              bank_of_china_account_hkd: user.profile.data['personal_information']['field_values']['bank_of_china_account_mop']
            )
            occupation_tax_item = OccupationTaxItem.find_or_create_by(user_id: user.id, year: self.year_month.beginning_of_year)
            occupation_tax_item.add_annual_award_info(item)
          end
        end
      end
      self.update_columns(status: :has_granted)
    end
  end

  def set_status
    self.update_columns(status: :calculating)
    self.calculate_later
  end

  def calculate_later
    AccountAnnualAwardItemsJob.perform_later(self)
  end


  def status_is_nil?
    self.status.nil?
  end

  def generate_item
    ProfileService.users6(self.year_month).each do |user|
      report = AttendAnnualReport.where(user_id: user.id, year: self.year_month.year).first
      had_calculate = report&.status == 'calculated'
      if report && !had_calculate
        report.set_data(self.year_month.year)
        report.reload
      end

      #7:应扣减天数
      #1‘无薪分娩假天数
      unpaid_maternity_leave_counts = if report
                                        report.unpaid_maternity_leave_counts || 0
                                      else
                                        0
                                      end
      #2’怀孕病假天数
      pregnant_sick_leave_counts = if report
                                     report.pregnant_sick_leave_counts || 0
                                   else
                                     0
                                   end

      #3‘停薪留职天数unpaid_but_maintain_position_counts
      unpaid_but_maintain_position_counts = if report
                                              report.unpaid_but_maintain_position_counts || 0
                                            else
                                              0
                                            end
      #4’旷工天数absenteeism_counts
      absenteeism_counts = if report
                             report.absenteeism_counts || 0
                           else
                             0
                           end
      #5‘即告天数immediate_leave_counts
      immediate_leave_counts = if report
                                 report.immediate_leave_counts || 0
                               else
                                 0
                               end
      #6’無薪假天數unpaid_leave_counts
      unpaid_leave_counts = if report
                              report.unpaid_leave_counts || 0
                            else
                              0
                            end
      #7‘工伤天数（7天后）work_injury_after_7_counts
      work_injury_after_7_counts = if report
                                     report.work_injury_after_7_counts || 0
                                   else
                                     0
                                   end
      #8’无薪病假天数unpaid_sick_leave_counts
      unpaid_sick_leave_counts = if report
                                   report.unpaid_sick_leave_counts || 0
                                 else
                                   0
                                 end
      #9’迟到超过120分钟late_mins_more_than_120
      late_mins_more_than_120 = if report
                                  report.late_mins_more_than_120 || 0
                                else
                                  0
                                end
      #10‘考勤異常導致曠工天數absenteeism_from_exception_counts
      absenteeism_from_exception_counts = if report
                                            report.absenteeism_from_exception_counts || 0
                                          else
                                            0
                                          end

      deducted_days = unpaid_maternity_leave_counts + pregnant_sick_leave_counts + unpaid_but_maintain_position_counts + absenteeism_counts +
        immediate_leave_counts + unpaid_leave_counts + work_injury_after_7_counts + unpaid_sick_leave_counts + late_mins_more_than_120 + absenteeism_from_exception_counts

      # 8 是否享有雙糧
      add_double_pay = ActiveModelSerializers::SerializableResource.new(user.welfare_records.by_current_valid_record_for_welfare_info.first).serializer_instance.double_pay rescue false
      # 9 双粮
      #todo：取值可以優化
      # 1‘ 底薪
      basic_salary = SalaryCalculatorService._calc_salary_element_raw(user, self.year_month.end_of_year.beginning_of_month, :final_basic_salary)
      # 2’ 津贴
      bonus = SalaryCalculatorService._calc_salary_element_raw(user, self.year_month.end_of_year.beginning_of_month, :final_bonus)
      # 3‘ 勤工
      attendance_award = SalaryCalculatorService._calc_salary_element_raw(user, self.year_month.end_of_year.beginning_of_month, :final_attendance_award)
      double_pay_hkd = (basic_salary + bonus + attendance_award) * (ProfileService.work_days_in_this_year(user, self.year_month) - deducted_days) / self.year_month.end_of_year.yday
      # 10 雙糧調整
      double_pay_alter_hkd = nil
      # 11 雙糧實發
      double_pay_final_hkd = double_pay_hkd + SalaryCalculatorService.math_add(double_pay_alter_hkd)
      # 12 是否享有花紅
      add_end_bonus = ActiveModelSerializers::SerializableResource.new(user.welfare_records.by_current_valid_record_for_welfare_info.first).serializer_instance.salary_composition == 'fixed' rescue false
      # 13 花紅應發
      # 发放规则
      grant_type_detail = GrantTypeDetail.where(user_id: user.id, annual_award_report_id: self.id).first
      #  花紅應發 =(「底薪」＊「底薪倍數」＋「津貼」＊「津貼倍數」＋「勤工」＊「勤工倍數」＋「固定金額」) * {「本年在職天數」-「應扣減天數」/「當年的總天數365或366」}
      end_bonus_hkd = BigDecimal(0);
      end_bonus_hkd += grant_type_detail.add_basic_salary ? basic_salary * grant_type_detail.basic_salary_time || 0 : BigDecimal(0)
      end_bonus_hkd += grant_type_detail.add_bonus ? bonus * grant_type_detail.bonus_time || 0 : BigDecimal(0)
      end_bonus_hkd += grant_type_detail.add_attendance_bonus ? attendance_award * grant_type_detail.attendance_bonus_time || 0 : BigDecimal(0)
      end_bonus_hkd += grant_type_detail.add_fixed_award ? SalaryCalculatorService.mop_to_hkd(SalaryCalculatorService.math_add(grant_type_detail.fixed_award_mop)) : BigDecimal(0)
      end_bonus_hkd = end_bonus_hkd * (ProfileService.work_days_in_this_year(user, self.year_month) - deducted_days) / self.year_month.end_of_year.yday
      # 14 支票/表揚信次數
      praise_times = user.award_records.where("year >= :year_begin AND year <= :year_end", year_begin: self.year_month.beginning_of_year, year_end: self.year_month.end_of_year).count
      # 15 花紅總增加
      end_bonus_add_hkd = end_bonus_hkd * praise_times * self.each_piece_of_awarding_deducting / 100
      # 16 全年曠工次數 absenteeism_counts late_mins_more_than_120 absenteeism_from_exception_counts
      absence_times = 0
      # 1' 全年曠工次數 - 矿工absenteeism_counts
      absence_times += if report
                         report.absenteeism_counts || 0
                       else
                         0
                       end
      # 2' 全年曠工次數 - 迟到120late_mins_more_than_120
      absence_times += if report
                         report.late_mins_more_than_120 || 0
                       else
                         0
                       end
      # 3' 全年曠工次數 - 考勤异常导致矿工absenteeism_from_exception_counts
      absence_times += if report
                         report.absenteeism_from_exception_counts || 0
                       else
                         0
                       end
      # 17 全年即告次數 immediate_leave_counts
      # notice_times = AttendAnnualReport.where(user_id: user.id, year: self.year_month.year).first&.immediate_leave_counts.to_i
      notice_times = if report
                       report.immediate_leave_counts || 0
                     else
                       0
                     end
      # 18 全年遲到次數 late_counts
      # late_times = AttendAnnualReport.where(user_id: user.id, year: self.year_month.year).first&.late_counts.to_i
      late_times = if report
                     report.late_counts || 0
                   else
                     0
                   end
      # 19 全年漏打上下班次數 signcard_forget_to_punch_in_counts signcard_forget_to_punch_out_counts
      lack_sign_card_times = 0
      lack_sign_card_times += if report
                                report.signcard_forget_to_punch_in_counts || 0
                              else
                                0
                              end
      lack_sign_card_times += if report
                                report.signcard_forget_to_punch_out_counts || 0
                              else
                                0
                              end
      # 20 處罰通知書次數
      punishment_times = user.punishments.where(
        'punishment_date >= :year_begin AND punishment_date <= :year_end',
        year_begin: self.year_month.beginning_of_year, year_end: self.year_month.end_of_year
      ).count
      # 21 扣減花紅_曠工
      de_end_bonus_for_absence_hkd = absence_times > 0 ? absence_times * end_bonus_hkd * self.absence_deducting / 100 : BigDecimal(0)
      # 22 扣減花紅_即告
      de_bonus_for_notice_hkd = notice_times > 0 ? notice_times * end_bonus_hkd * self.notice_deducting / 100 : BigDecimal(0)

      # late_times_for_calc = (late_times - 5) >= 0 ? (late_times - 5) : BigDecimal(0)
      # 23 扣減花紅_遲到
      de_end_bonus_for_late_hkd = (late_times - 5) >= 0 ? (late_times - 5) * end_bonus_hkd * self.notice_deducting / 100 : BigDecimal(0)
      # 24 扣減花紅_漏打卡上下班
      de_end_bonus_for_sign_card_hkd = lack_sign_card_times > 0 ? lack_sign_card_times * end_bonus_hkd * self.sign_card_deducting / 100 : BigDecimal(0)
      # 25 扣減花紅_處罰通知書
      # 扣減花紅_處罰通知書 - 次数
      warning_times = punishment_times
      # 扣減花紅_處罰通知書 - 比例
      warning_times_for_calc = if warning_times == 1
                                 self.one_letter_of_warning_deducting
                               elsif warning_times >= 2
                                 self.two_letters_of_warning_deducting
                               else
                                 BigDecimal(0)
                               end
      de_end_bonus_for_punishment_hkd = end_bonus_hkd * warning_times_for_calc / 100
      # 26 花紅總扣減
      de_bonus_total_hkd = de_end_bonus_for_absence_hkd + de_bonus_for_notice_hkd + de_end_bonus_for_late_hkd +
        de_end_bonus_for_sign_card_hkd + de_end_bonus_for_punishment_hkd rescue 0
      # 27 花紅實發
      end_bonus_final_hkd = end_bonus_hkd + end_bonus_add_hkd - de_bonus_total_hkd rescue 0
      # 28 上年度是否全勤
      present_at_duty_first_half = ProfileService.is_attend_the_whole_year(user, self.year_month)
      # 29 全年勤工基數
      annual_at_duty_basic_hkd = self.annual_attendance_award_hkd
      # 30 全年勤工實發
      annual_at_duty_final_hkd = annual_at_duty_basic_hkd * (ProfileService.work_days_in_this_year(user, self.year_month) - deducted_days) / self.year_month.end_of_year.end_of_year.yday

      AnnualAwardReportItem.create!(
        user_id: user.id,
        department_id: user.department_id,
        position_id: user.position_id,
        date_of_employment: ProfileService.employment_of_date(user),
        work_days_this_year: ProfileService.work_days_in_this_year(user, self.year_month),
        deducted_days: deducted_days,
        annual_award_report_id: self.id,
        add_double_pay: add_double_pay,
        double_pay_hkd: add_double_pay ? double_pay_hkd : nil,
        double_pay_alter_hkd: add_double_pay ? double_pay_alter_hkd : nil,
        double_pay_final_hkd: add_double_pay ? double_pay_final_hkd : nil,
        add_end_bonus: add_end_bonus,
        end_bonus_hkd: add_end_bonus ? end_bonus_hkd : nil,
        praise_times: praise_times,
        end_bonus_add_hkd: add_end_bonus ? end_bonus_add_hkd : nil,
        absence_times: absence_times,
        notice_times: notice_times,
        late_times: late_times,
        lack_sign_card_times: lack_sign_card_times,
        punishment_times: punishment_times,
        de_end_bonus_for_absence_hkd: add_end_bonus ? de_end_bonus_for_absence_hkd : nil,
        de_bonus_for_notice_hkd: add_end_bonus ? de_bonus_for_notice_hkd : nil,
        de_end_bonus_for_late_hkd: add_end_bonus ? de_end_bonus_for_late_hkd : nil,
        de_end_bonus_for_sign_card_hkd: add_end_bonus ? de_end_bonus_for_sign_card_hkd : nil,
        de_end_bonus_for_punishment_hkd: add_end_bonus ? de_end_bonus_for_punishment_hkd : nil,
        de_bonus_total_hkd: add_end_bonus ? de_bonus_total_hkd : nil,
        end_bonus_final_hkd: add_end_bonus ? end_bonus_final_hkd : nil,
        present_at_duty_first_half: present_at_duty_first_half,
        annual_at_duty_basic_hkd: present_at_duty_first_half ? annual_at_duty_basic_hkd : nil,
        annual_at_duty_final_hkd: present_at_duty_first_half ? annual_at_duty_final_hkd : nil
      )
    end
  end

  def self.create_with_params(params)
    aar = nil
    ActiveRecord::Base.transaction do
      aar = self.create!(year_month: params[:year_month],
                         annual_attendance_award_hkd: params[:annual_attendance_award_hkd],
                         annual_bonus_grant_type: params[:annual_bonus_grant_type],
                         grant_type_rule: params[:grant_type_rule],
                         absence_deducting: params[:absence_deducting],
                         notice_deducting: params[:notice_deducting],
                         late_5_times_deducting: params[:late_5_times_deducting],
                         sign_card_deducting: params[:sign_card_deducting],
                         one_letter_of_warning_deducting: params[:one_letter_of_warning_deducting],
                         two_letters_of_warning_deducting: params[:two_letters_of_warning_deducting],
                         each_piece_of_awarding_deducting: params[:each_piece_of_awarding_deducting],
                         method_of_settling_accounts: params[:method_of_settling_accounts],
                         award_date: params[:award_date]
      )
      if aar.valid?
        ids = ProfileService.users6(aar.year_month).ids
        case aar.annual_bonus_grant_type
        when 'all'
          all_rule = aar.grant_type_rule.first.reject { |k, v| k == 'key' }
          User.where(id: ids).each do |user|
            GrantTypeDetail.create!(all_rule.merge({user_id: user.id, annual_award_report_id: aar.id}))
          end
        when 'departments'
          department_rules = aar.grant_type_rule
          User.where(id: ids).each do |user|
            department_rule = department_rules.select { |hash| hash['key'].to_i == user.department_id }.first.reject { |k, v| k == 'key' }
            GrantTypeDetail.create!(department_rule.merge({user_id: user.id, annual_award_report_id: aar.id}))
          end
        when 'division_of_job'
          division_rules = aar.grant_type_rule
          User.where(id: ids).each do |user|
            division_rule = division_rules.select { |hash| hash['key'] == user.profile.data['position_information']['field_values']['division_of_job'] }.first.reject { |k, v| k == 'key' }
            GrantTypeDetail.create!(division_rule.merge({user_id: user.id, annual_award_report_id: aar.id}))
          end
        end
      end
    end
    aar.set_status
    aar
  end

  def self.grant_type_options
    {
      departments: Department.all.as_json,
      division_of_jobs: Config.get_all_option_from_selects(:division_of_job),
      all: [{
              key: 'all',
              chinese_name: '全部員工',
              english_name: 'all_staffs',
              simple_chinese_name: '全部员工'
            }]
    }
  end

end
