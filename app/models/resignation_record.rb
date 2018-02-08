# == Schema Information
#
# Table name: resignation_records
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  status                     :string
#  time_arrive                :string
#  resigned_date              :datetime
#  resigned_reason            :string
#  reason_for_resignation     :string
#  employment_status          :string
#  department_id              :integer
#  position_id                :integer
#  comment                    :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  compensation_year          :boolean
#  notice_period_compensation :boolean
#  valid_date                 :datetime
#  invalid_date               :datetime
#  order_key                  :string
#  notice_date                :datetime
#  final_work_date            :datetime
#  is_in_whitelist            :boolean          default(TRUE)
#
# Indexes
#
#  index_resignation_records_on_user_id  (user_id)
#

class ResignationRecord < ApplicationRecord
  include RecordCallbackAble
  include ResignationRecordValidators
  validates :user_id, :resigned_reason, :reason_for_resignation, :employment_status, :notice_date, presence: true
  has_many :salary_values
  #resignation: 员工辞职
  #termination: 终止雇佣
  #company_transfer_personal_request: 跨公司調職(個人申請)
  #company_transfer_department_request： 跨公司調職(部門申請)
  #retirement： 退休
  #others： 其他
  #lay_off: 遣散
  validates :resigned_reason, inclusion: {in: %w(resignation termination company_transfer_personal_request
company_transfer_department_request retirement others lay_off)}

  #job_description：工作職能
  #family_or_other_external_reason：家庭或其他外在因素
  #employee_benefits：員工福利待遇
  #career_development： 職業發展
  #personal_career_development： 個人生涯發展
  #personal_reason： 個人因素
  #relationship： 人際關係
  #others：其他
  validates :reason_for_resignation, inclusion: {in: %w(job_description family_or_other_external_reason employee_benefits
career_development personal_career_development personal_reason relationship others)}

  #informal_employees: 非正式員工
  #formal_employees: 正式員工
  #director: 總監員工
  #president: 總裁員工
  #director_in_informal: 總監(非正式)
  #president_in_informal: 總裁(非正式)
  #part_time: 兼職
  #trainee: 實習生


  validates :employment_status, inclusion: {in: %w(informal_employees formal_employees director president director_in_informal
president_in_informal part_time trainee)}
  validates :status, inclusion: {in: %w(to_be_valid being_valid invalid)}, unless: :status_not_filled?
  validates :time_arrive, inclusion: {in: %w(arrived coming)}, unless: :time_arrive_not_filled?
  validates :compensation_year, :notice_period_compensation, :is_in_whitelist, inclusion: {in: [false, true]}
  validates :final_work_date, :notice_date, presence: true
  validates_with ResignationRecordValidator
  belongs_to :user

  after_create :set_status
  after_update :invalided_other_records, if: :is_being_valid?
  after_update :set_time_arrive
  # before_destroy :valid_status
  after_update :update_position_resigned_date
  after_destroy :clear_resigned_date

  before_destroy :destroy_all_salary_values, if: :salary_value_can_be_destroy?

  def destroy_all_salary_values
    self.salary_values.destroy_all
  end

  def salary_value_can_be_destroy?
   if self.salary_values.where(salary_column_id: 0).first&.string_value == 'not_granted'
     true
   else
     throw :abort
   end
  end

  def clear_resigned_date
    ProfileService.update_resigned_date(self.user)
  end

  def update_position_resigned_date
    if self.status.to_sym == :being_valid
      position_resigned_date = Time.zone.parse(self.profile.data['position_information']['field_values']['resigned_date']).beginning_of_day rescue nil
      if position_resigned_date != self.resigned_date.beginning_of_day
        profile = self.user.profile
        profile.send(
          :edit_field, {field: 'resigned_date', new_value: self.resigned_date.strftime('%Y/%m/%d'), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
    end
  end

  def self.update_records
    self.where(status: :being_valid).order(resigned_date: :asc).each  do |record|
      record.set_time_arrive
    end
  end

  def time_arrive_not_filled?
    self.time_arrive.nil?
  end

  def status_not_filled?
    self.status.nil?
  end

  def is_being_valid?
    status == 'being_valid'
  end


  def set_status
    msr = MonthSalaryReport.find_or_create_by(year_month: self.resigned_date.beginning_of_month, salary_type: :left)
    msr.calculate_leaving_salary_record_by_user(self.user,self.id)
    self.update(status: :being_valid, valid_date: Time.zone.now) if self == self.user.resignation_records.order(resigned_date: :desc).first
  end

  def invalided_other_records
    self.class.where(user_id: self.user_id, status: :being_valid).where.not(id: self).update(status: :invalid, time_arrive: nil, invalid_date: Time.zone.now)
  end

  def set_time_arrive
    if self.status == 'being_valid'
      if self.resigned_date < Time.zone.now.end_of_day
        self.update(time_arrive: :arrived) unless self.time_arrive == 'arrived'
      else
        self.update(time_arrive: :coming) unless self.time_arrive == 'coming'
      end
    end
  end

  def self.resignation_information_options
    {
      resigned_reason: Config.get_all_option_from_selects(:resigned_reason),
      reason_for_resignation: Config.get_all_option_from_selects(:reason_for_resignation),
      employment_status: Config.get_all_option_from_selects(:employment_status),
      department_id: Department.all,
      position_id: Position.all,
      compensation_year: Config.get_all_option_from_selects(:compensation_year),
      notice_period_compensation: Config.get_all_option_from_selects(:notice_period_compensation),
    }
  end
end
