# == Schema Information
#
# Table name: job_transfers
#
#  id                         :integer          not null, primary key
#  region                     :string
#  apply_date                 :date
#  user_id                    :integer
#  transfer_type              :integer
#  position_start_date        :date
#  position_end_date          :date
#  apply_result               :boolean
#  trial_expiration_date      :date
#  new_location_id            :integer
#  new_department_id          :integer
#  new_position_id            :integer
#  new_grade                  :integer
#  instructions               :string
#  original_location_id       :integer
#  original_department_id     :integer
#  original_position_id       :integer
#  original_grade             :integer
#  inputter_id                :integer
#  input_date                 :date
#  comment                    :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  new_company_name           :string
#  original_company_name      :string
#  new_employment_status      :string
#  original_employment_status :string
#  salary_calculation         :string
#  transferable_id            :integer
#  transferable_type          :string
#  new_group_id               :integer
#  original_group_id          :integer
#
# Indexes
#
#  index_job_transfers_on_inputter_id                            (inputter_id)
#  index_job_transfers_on_new_department_id                      (new_department_id)
#  index_job_transfers_on_new_location_id                        (new_location_id)
#  index_job_transfers_on_new_position_id                        (new_position_id)
#  index_job_transfers_on_original_department_id                 (original_department_id)
#  index_job_transfers_on_original_location_id                   (original_location_id)
#  index_job_transfers_on_original_position_id                   (original_position_id)
#  index_job_transfers_on_transferable_id_and_transferable_type  (transferable_id,transferable_type)
#  index_job_transfers_on_user_id                                (user_id)
#

class JobTransfer < ApplicationRecord
  include UserSortAble
  belongs_to :transferable, polymorphic: true
  belongs_to :user
  belongs_to :inputter, :class_name => "User", :foreign_key => "inputter_id"
  belongs_to :new_location, class_name: 'Location', foreign_key: :new_location_id
  belongs_to :original_location, class_name: 'Location', foreign_key: :original_location_id
  belongs_to :new_department, class_name: 'Department', foreign_key: :new_department_id
  belongs_to :original_department, class_name: 'Department', foreign_key: :original_department_id
  belongs_to :new_position, class_name: 'Position', foreign_key: :new_position_id
  belongs_to :original_position, class_name: 'Position', foreign_key: :original_position_id
  belongs_to :new_group, class_name: 'Group', foreign_key: :new_group_id
  belongs_to :original_group, class_name: 'Group', foreign_key: :original_group_id

  validates :apply_date, presence: true
  validates :apply_result, inclusion: { in: [ true, false ] }
  validates :user_id, presence: true
  validates :transfer_type, presence: true

  enum transfer_type: { pass_entry_trial: 0, pass_transfer_trial: 1, special_assessment: 2,
                        transfer_position_apply_by_employee: 3, transfer_position_apply_by_department: 4,
                        transfer_location_apply: 5, lent_temporarily: 6 }
  def self.options
    {
      transfer_type: self.transfer_types,
      apply_result: [
        {
          key: true,
          chinese_name: '通過',
          simple_chinese_name: '通过',
          english_name: 'pass',
        },
        {
          key: false,
          chinese_name: '未通過',
          simple_chinese_name: '未通过',
          english_name: 'failed'
        }
      ],
      salary_calculation: Config.get_all_option_from_selects(:salary_calculation),
      new_company_name: Config.get_all_option_from_selects(:company_name),
      original_company_name: Config.get_all_option_from_selects(:company_name),
      new_location_id: JobTransfer.joins(:new_location).select('locations.*').distinct.as_json,
      new_department_id: JobTransfer.joins(:new_department).select('departments.*').distinct.as_json,
      new_position_id: JobTransfer.joins(:new_position).select('positions.*').distinct.as_json,
      new_group_id: JobTransfer.joins(:new_group).select("groups.*").distinct.as_json,
      original_location_id: JobTransfer.joins(:original_location).select('locations.*').distinct.as_json,
      original_department_id: JobTransfer.joins(:original_department).select('departments.*').distinct.as_json,
      original_position_id: JobTransfer.joins(:original_position).select('positions.*').distinct.as_json,
      original_group_id: JobTransfer.joins(:original_group).select("groups.*").distinct.as_json,
      new_grade: Config.get_all_option_from_selects(:grade),
      orignal_grade: Config.get_all_option_from_selects(:grade),
      new_employment_status: Config.get_all_option_from_selects(:employment_status),
      original_employment_status: Config.get_all_option_from_selects(:employment_status),
    }
  end

  def self.transfer_types
    [
      {
        key: 'pass_entry_trial',
        chinese_name: '通過入職試用期',
        english_name: 'Through entry  probation',
        simple_chinese_name: '通过入职试用期'
      },
      {
        key: 'pass_transfer_trial',
        chinese_name: '通過調職試用期',
        english_name: 'Through  transfer probation',
        simple_chinese_name: '通过调职试用期'
      },
      {
        key: 'special_assessment',
        chinese_name: '特別評估',
        english_name: 'Special-assess',
        simple_chinese_name: '特别评估'
      },
      {
        key: 'transfer_position_apply_by_employee',
        chinese_name: '調職（員工發起）',
        english_name: 'Transfer (staff initiated)',
        simple_chinese_name: '调职（员工发起）'
      },
      {
        key: 'transfer_position_apply_by_department',
        chinese_name: '調職（部門發起）',
        english_name: 'Transfer (department initiated)',
        simple_chinese_name: '调职（部门发起）'
      },
      {
        key: 'transfer_location_apply',
        chinese_name: '調館',
        english_name: 'Transfer the location',
        simple_chinese_name: '调馆'
      },
      {
        key: 'lent_temporarily',
        chinese_name: '暫借',
        english_name: 'Lent',
        simple_chinese_name: '暂借'
      }
    ]
  end


  scope :by_apply_date, lambda { |apply_date_start, apply_date_end|
    if apply_date_start && apply_date_end
      where(apply_date: apply_date_start..apply_date_end)
    elsif apply_date_start
      where("apply_date >= :apply_date_start", apply_date_start: apply_date_start)
    elsif apply_date_end
      where("apply_date <= :apply_date_end", apply_date_end: apply_date_end)
    end
  }


  scope :by_employee_name, lambda { |employee_name, lang|
    if employee_name
      employee_ids = User.where("#{lang} like ?", "%#{employee_name}%")
      where(user_id: employee_ids)
    end
  }

  scope :by_empoid, lambda { |empoid|
    if empoid
      employee_ids = User.where(empoid: empoid)
      where(user_id: employee_ids)
    end
  }

  scope :by_date_of_employment, lambda { |date_of_employment|
    if params[:date_of_employment]
      user_ids = []
      range = date_of_employment[:begin].in_time_zone.to_date .. date_of_employment[:end].in_time_zone.to_date
      query = self
      query.all.each do |t|
        user = User.find_by(id: t.user_id)
        if user && range.include?(user.profile.data['position_information']['field_values']['date_of_employment']&.in_time_zone&.to_date)
          user_ids += [user.id]
        end
      end
      query = query.where(user_id: user_ids)
      query
    end
  }

  scope :by_position_resigned_date, lambda { |position_resigned_date|
    if params[:position_resigned_date]
      user_ids = []
      range = position_resigned_date[:begin].in_time_zone.to_date .. position_resigned_date[:end].in_time_zone.to_date
      query = self
      query.all.each do |t|
        user = User.find_by(id: t.user_id)
        if user && range.include?(user.profile.data['position_information']['field_values']['resigned_date']&.in_time_zone&.to_date)
          user_ids += [user.id]
        end
      end
      query = query.where(user_id: user_ids)
      query
    end
  }

  scope :by_position_start_date, lambda { |position_start_date_start, position_start_date_end|
    if position_start_date_start && position_start_date_end
      where(position_start_date: position_start_date_start..position_start_date_end)
    elsif position_start_date_start
      where("position_start_date >= :position_start_date_start", position_start_date_start: position_start_date_start)
    elsif position_start_date_end
      where("position_start_date <= :position_start_date_end", position_start_date_end: position_start_date_end)
    end
  }

  scope :by_position_end_date, lambda { |position_end_date_start, position_end_date_end|
    if position_end_date_start && position_end_date_end
      where(position_end_date: position_end_date_start..position_end_date_end)
    elsif position_end_date_start
      where("position_end_date >= :position_end_date_start", position_end_date_start: position_end_date_start)
    elsif position_end_date_end
      where("position_end_date <= :position_end_date_end", position_end_date_end: position_end_date_end)
    end
  }

  scope :by_trial_expiration_date, lambda { |trial_expiration_date_start, trial_expiration_date_end|
    if trial_expiration_date_start && trial_expiration_date_end
      where(trial_expiration_date: trial_expiration_date_start..trial_expiration_date_end)
    elsif trial_expiration_date_start
      where("trial_expiration_date >= :trial_expiration_date_start", trial_expiration_date_start: trial_expiration_date_start)
    elsif trial_expiration_date_end
      where("trial_expiration_date <= :trial_expiration_date_end", trial_expiration_date_end: trial_expiration_date_end)
    end
  }

  scope :by_inputter, lambda { |inputter, lang|
    if inputter
      inputter_ids = User.where("#{lang} like ?", "%#{inputter}%")
      where(inputter_id: inputter_ids)
    end
  }

  scope :by_input_date, lambda { |input_date_start, input_date_end|
    if input_date_start && input_date_end
      where(input_date: input_date_start..input_date_end)
    elsif input_date_start
      where("input_date >= :input_date_start", input_date_start: input_date_start)
    elsif input_date_end
      where("input_date <= :input_date_end", input_date_end: input_date_end)
    end
  }

  scope :by_transfer_type, lambda { |type, lang|
    where(transfer_type: type) if type
  }

  scope :by_apply_result, lambda { |result|
    where(apply_result: result) unless result.nil?
  }

  scope :by_salary_calculation, lambda { |salary_calculation, lang|
    if salary_calculation
      where(salary_calculation: salary_calculation)
    end
  }

  scope :by_new_company_name, lambda { |new_company_name, lang|
    if new_company_name
      where(new_company_name: new_company_name)
    end
  }

  scope :by_new_location_id, lambda { |new_location_id|
    if new_location_id
      where(new_location_id: new_location_id)
    end
  }

  scope :by_new_department_id, lambda { |new_department_id|
    if new_department_id
      where(new_department_id: new_department_id)
    end
  }

  scope :by_new_position_id, lambda { |new_position_id|
    if new_position_id
      where(new_position_id: new_position_id)
    end
  }

  scope :by_new_grade, lambda { |new_grade|
    where(new_grade: new_grade) if new_grade
  }

  scope :by_new_employment_status, lambda { |new_employment_status, lang|
    if new_employment_status
      where(new_employment_status: new_employment_status)
    end
  }

  scope :by_new_group_id, lambda { |new_group_id, lang|
    if new_group_id
      where(new_group_id: new_group_id)
    end
  }

  scope :by_original_group_id, lambda { |original_group_id, lang|
    if original_group_id
      where(original_group_id: original_group_id)
    end
  }

  scope :by_original_company_name, lambda { |original_company_name, lang|
    if original_company_name
      where(original_company_name: original_company_name)
    end
  }

  scope :by_original_location_id, lambda { |original_location_id|
    if original_location_id
      where(original_location_id: original_location_id)
    end
  }

  scope :by_original_department_id, lambda { |original_department_id|
    if original_department_id
      where(original_department_id: original_department_id)
    end
  }

  scope :by_original_position_id, lambda { |original_position_id|
    if original_position_id
      where(original_position_id: original_position_id)
    end
  }

  scope :by_original_grade, lambda { |original_grade|
    where(original_grade: original_grade) if original_grade
  }

  scope :by_original_employment_status, lambda { |original_employment_status, lang|
    if original_employment_status
      where(original_employment_status: original_employment_status)
    end
  }
  scope :by_date_of_employment, lambda{|from, to|
    if from && to
      includes(user: :profile)
        .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from ", from: from)
        .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }
  scope :by_position_resigned_date, lambda{|from, to|
    if from && to
      includes(user: :profile)
        .where("profiles.data #>> '{position_information, field_values, resigned_date}' >= :from ", from: from)
        .where("profiles.data #>> '{position_information, field_values, resigned_date}' <= :to", to: to)
    elsif from
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, resigned_date}' >= :from", from: from)
    elsif to
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, resigned_date}' <= :to", to: to)
    end
  }

  scope :order_by, lambda {|sort_column, sort_direction|
    case sort_column.to_s
      when 'employee_name'                 then joins(:user).order("users.#{select_language.to_s} #{sort_direction}")
      when 'empoid'                        then joins(:user).order("users.empoid #{sort_direction}")
      when 'inputter'                      then joins(:inputter).order("users.#{select_language.to_s} #{sort_direction}")
    when 'date_of_employment'
      if sort_direction == :desc
        joins(user: :profile).order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
      else
        joins(user: :profile).order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
      end
    when 'position_resigned_date'
      if sort_direction == :desc
        joins(user: :profile).order("profiles.data #>> '{position_information, field_values, resigned_date}' DESC")
      else
        joins(user: :profile).order("profiles.data #>> '{position_information, field_values, resigned_date}' ")
      end
    else order(sort_column => sort_direction)
    end
  }

end
