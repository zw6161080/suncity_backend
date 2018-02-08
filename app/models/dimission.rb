# == Schema Information
#
# Table name: dimissions
#
#  id                                             :integer          not null, primary key
#  user_id                                        :integer
#  apply_date                                     :date
#  inform_date                                    :date
#  last_work_date                                 :date
#  is_in_blacklist                                :boolean
#  comment                                        :text
#  last_salary_begin_date                         :date
#  last_salary_end_date                           :date
#  remaining_annual_holidays                      :integer
#  apply_comment                                  :text
#  resignation_reason                             :jsonb
#  resignation_reason_extra                       :string
#  resignation_future_plan                        :jsonb
#  resignation_future_plan_extra                  :string
#  resignation_is_inform_period_exempted          :boolean
#  resignation_inform_period_penalty              :integer
#  resignation_is_recommanded_to_other_department :boolean
#  termination_reason                             :jsonb
#  termination_reason_extra                       :string
#  termination_inform_peroid_days                 :integer
#  termination_is_reasonable                      :boolean
#  termination_compensation_extra                 :string
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  dimission_type                                 :string
#  creator_id                                     :integer
#  holiday_cut_off_date                           :date
#  resignation_certificate_languages              :jsonb
#  career_history_dimission_reason                :string           not null
#  career_history_dimission_comment               :text
#  termination_compensation                       :integer
#  company_name                                   :string
#  final_work_date                                :datetime
#  is_compensation_year                           :boolean
#  notice_period_compensation                     :boolean
#  group_id                                       :integer
#
# Indexes
#
#  index_dimissions_on_creator_id  (creator_id)
#  index_dimissions_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_1fa9498806  (creator_id => users.id)
#  fk_rails_3284087b92  (user_id => users.id)
#

class Dimission < ApplicationRecord
  belongs_to :user
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  has_many :dimission_follow_ups
  has_many :approval_items, as: :approvable
  has_many :attachment_items, as: :attachable
  belongs_to :group
  # validates :apply_date, :inform_date, :last_work_date, :final_work_date

  # validates :is_compensation_year, :is_in_blacklist, :notice_period_compensation, inclusion: {in: [true, false]}

  enum dimission_type: {resignation: 'resignation', termination: 'termination'}



  def self.create_params
    super - %w(creator_id)
  end

  def self.field_options
    user_query = self.left_outer_joins(:group, user: [:location, :position, :department])
    locations = user_query.select('locations.*').distinct.as_json
    positions = user_query.select('positions.*').distinct.as_json
    departments = user_query.select('departments.*').distinct.as_json
    groups = user_query.select('groups.*').distinct.as_json
    return {
      locations: locations,
      positions: positions,
      departments: departments,
      groups: groups,
      company_names: Config.get_all_option_from_selects('company_name')
    }
  end

  def self.termination_compensation(user, is_reasonable_termination, last_work_date)
    if is_reasonable_termination
      return false
    end
    career_history = user.career_records

    if career_history.count == 0
      return 0
    end

    if ProfileService.whether_foreign_employee(user)
      # 外地僱員
      if career_history.by_current_valid_record_for_career_info.first.present?
        job_termination_date = career_history.by_current_valid_record_for_career_info.first.career_end
        one_month = job_termination_date.mday - last_work_date.mday > 0 ? 1 : 0
        days = (job_termination_date.month - last_work_date.month + one_month + (job_termination_date.year - last_work_date.year )* 12 ) * 3
        return days > 0 ? days : 0
      else
        0
      end
    else
      # 本地僱員
      if career_history.by_current_valid_record_for_career_info.first.present?
        entry_date = career_history.by_current_valid_record_for_career_info.first.career_begin
        days = last_work_date.year * 12 + last_work_date.month - entry_date.year * 12 - entry_date.month
        days += 1 if last_work_date.day >= 15
        days = (BigDecimal(days) / BigDecimal(12)).round(2)
        return days > 0 ? days : 0
      else
        return 0
      end
    end
  end

  def self.create_with_params(dimission_params, follow_ups, approval_items, attachment_items, resignation_record)
    dimission = nil
    ActiveRecord::Base.transaction do
      # Self Model
      dimission = Dimission.create!(dimission_params)

      # Follow ups Associations
      follow_ups.each do |item_params|
        dimission.dimission_follow_ups.create(item_params)
      end if follow_ups

      # Approval Items Associations
      approval_items.each do |item_params|
        dimission.approval_items.create(item_params)
      end if approval_items

      # Attachment Items Association
      attachment_items.each do |item_params|
        dimission.attachment_items.create(item_params)
      end if attachment_items

      dimission.save!
      dimission.append_profile_resignation_information(resignation_record)
    end
    dimission.try(:id)
  end

  def self.detail_by_id(id)
    Dimission
      .includes({user: [:department, :position]},
                {dimission_follow_ups: [:handler]},
                approval_items: [:user],
                attachment_items: [:creator, :attachment])
      .find(id)
  end

  def append_profile_resignation_information(**args)
    test = self.user.resignation_records.create!(
      resigned_date: self.last_work_date,
      resigned_reason: self.dimission_type,
      reason_for_resignation: args[:reason_for_resignation],
      employment_status: self.user.employment_status,
      department_id: self.user.department_id,
      position_id: self.user.position_id,
      comment: args[:comment],
      compensation_year: !self.termination_is_reasonable,
      notice_period_compensation: !!self.notice_period_compensation,
      notice_date: self.inform_date,
      final_work_date: self.final_work_date,
      is_in_whitelist: !self.is_in_blacklist,
    )
    test
  end

  def create_dismission_salary_item
    DismissionSalaryItem.generate(self)
  end

  scope :join_users_query, lambda {
    joins(user: [:department, :position, :location], creator:{})
  }

  scope :by_group_id, lambda {|group_id|
    where(group_id: group_id) if group_id
  }

  scope :by_final_work_date, lambda {|from, to|
    if from && to
      where("final_work_date >= :from  && final_work_date <= :to", from: from, to: to)
    elsif from
      where("final_work_date >= :from", from: from)
    elsif to
      where("final_work_date <= :to", to: to)
    end
  }

  scope :by_company_name, lambda {|company_name|
    where(company_name: company_name) if company_name
  }

  scope :by_apply_date, lambda { |from, to|
    where(apply_date: from..to) if from && to
  }

  scope :by_inform_date, lambda { |from, to|
    where(inform_date: from..to) if from && to
  }

  scope :by_last_work_date, lambda { |from, to|
    where(last_work_date: from..to)
  }

  scope :by_type, lambda { |type|
    where(dimission_type: type)
  }

  scope :by_created_at, lambda { |from, to|
    where(created_at: from..to)
  }

  scope :by_creator_id, lambda { |creator_id|
    where(creator_id: creator_id)
  }

  scope :by_users_employee_no, lambda { |empoid|
    where(users: {empoid: empoid})
  }

  scope :by_users_location_id, lambda { |location_id|
    where(users: {location_id: location_id})
  }

  scope :by_users_department_id, lambda { |department_id|
    where(users: {department_id: department_id})
  }

  scope :by_users_position_id, lambda { |position_id|
    where(users: {position_id: position_id})
  }

  scope :by_users_employee_name, lambda { |employee_name|
    where(users: {select_language => employee_name})
  }

  scope :by_creator_name, lambda { |creator_name|
    where(creators_dimissions: {select_language => creator_name})
  }

end
