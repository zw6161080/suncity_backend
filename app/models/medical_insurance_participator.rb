# == Schema Information
#
# Table name: medical_insurance_participators
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  participate       :string
#  participate_date  :datetime
#  cancel_date       :datetime
#  monthly_deduction :decimal(10, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  to_status         :string
#  valid_date        :datetime
#  profile_id        :integer
#  operator_id       :integer
#
# Indexes
#
#  index_medical_insurance_participators_on_cancel_date       (cancel_date)
#  index_medical_insurance_participators_on_participate       (participate)
#  index_medical_insurance_participators_on_participate_date  (participate_date)
#  index_medical_insurance_participators_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_492fd3d450  (user_id => users.id)
#

class MedicalInsuranceParticipator < ApplicationRecord
  include MedicalInsuranceParticipatorValidators
  validates_with ParticipateWithMedicalTemplateValidator
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'

  validates :participate, inclusion: { in: ['participated', 'not_participated', nil], message: '%{value} is not a valid participate' }
  validates :to_status, inclusion: {in: ['participated_in_the_future', 'not_participated_in_the_future', nil], message: '%{value}  is not a valid to_status'}

  validates :participate, :profile_id, presence: true

  enum participate: { participated:     'medical_insurance_paticipator.enum_participate.participated',
                      not_participated: 'medical_insurance_paticipator.enum_participate.not_participated' }

  enum to_status: {
    participated_in_the_future:  'medical_insurance_paticipator.enum_participate.participated',
    not_participated_in_the_future: 'medical_insurance_paticipator.enum_participate.not_participated'
  }

  after_initialize :init
  after_save :set_monthly_deduction

  def self.auto_update
    self.all.each do |item|
      to_status = item.to_status
      valid_date = item.valid_date
      if  to_status.nil?
        next
      end
      ActiveRecord::Base.transaction do
        update_params = if valid_date < Time.zone.now.next_day.beginning_of_day
                          if to_status ==  'not_participated_in_the_future'
                            MedicalRecord.create!(user_id: item.user_id, participate: false, participate_begin: valid_date)
                            {participate: 'not_participated', valid_date: nil, to_status: nil, cancel_date: valid_date, monthly_deduction: BigDecimal(0)}
                          else
                            MedicalRecord.create!(user_id: item.user_id, participate: true, participate_begin: valid_date)
                            {participate: 'participated', valid_date: nil, to_status: nil, participate_date: valid_date, monthly_deduction: BigDecimal('50')}
                          end
                        end
        unless update_params
          next
        end
        item.update(update_params)
      end
    end
  end

  def medical_template_id
    MedicalTemplateSetting.first.sections.select{|hash| hash['employee_grade'].to_i == self.user.grade}.first['current_template_id'] if self.participate == 'participated'
  end

  def set_monthly_deduction
    if self.participate == 'participated'
      self.update_columns(monthly_deduction: Config.get(:constants_collection)['MedicalInsuranceParticipator'])
    end
  end

  def init
    self.participate  ||= 'not_participated'           #will set the default value only if it's nil
  end


  def participate_is_nil?
    self.participate.nil?
  end

  def to_status_is_nil?
    self.to_status.nil?
  end

  def self.create_with_params(params, profile, operator_id)
    ActiveRecord::Base.transaction do
    medical_insurance_participator = profile.build_medical_insurance_participator(user_id: profile.user_id, operator_id: operator_id)
    to_status = params['to_status']
    valid_date = Time.zone.parse(params['valid_date']) rescue nil
    unless valid_date
      return false
    end
    create_params = if valid_date && valid_date >= Time.zone.now.next_day.beginning_of_day
                      if to_status == 'not_participated_in_the_future'
                        { participate: 'not_participated', monthly_deduction: BigDecimal(0)}
                      else
                        { participate: 'not_participated', valid_date: valid_date , to_status: to_status, participate_date: valid_date,  monthly_deduction: BigDecimal(0)}
                      end
                    elsif valid_date && valid_date < Time.zone.now.next_day.beginning_of_day
                      if to_status ==  'not_participated_in_the_future'
                        {participate: 'not_participated', valid_date: nil, to_status: nil, cancel_date: valid_date, monthly_deduction: BigDecimal(0)}
                      else
                        MedicalRecord.create!(user_id: profile.user_id, participate: true, participate_begin: valid_date, creator_id: operator_id)
                        {participate: 'participated', valid_date: nil, to_status: nil, participate_date: valid_date, monthly_deduction: BigDecimal('50')}
                      end
                    end
    medical_insurance_participator.attributes = create_params
    medical_insurance_participator.save
    end
  end

  def update_with_params(params, operator_id)
    ActiveRecord::Base.transaction do
      to_status = params['to_status']
      valid_date =Time.zone.parse(params['valid_date']) rescue nil
      unless valid_date
        return false
      end
      if to_status == 'not_participated_in_the_future'
        if self.participate == 'not_participated'
          return false
        end
      else
        if self.participate == 'participated'
          return false
        end
      end
      update_params = if valid_date && valid_date >= Time.zone.now.next_day.beginning_of_day
                        if to_status == 'not_participated_in_the_future'
                          { valid_date: valid_date , to_status: to_status, cancel_date: valid_date}
                        else
                          { valid_date: valid_date , to_status: to_status, participate_date: valid_date}
                        end
                      elsif valid_date && valid_date < Time.zone.now.next_day.beginning_of_day
                        if to_status ==  'not_participated_in_the_future'
                          MedicalRecord.create!(user_id: self.user_id, participate: false, participate_begin: valid_date, creator_id: operator_id)
                          {participate: 'not_participated', valid_date: nil, to_status: nil, cancel_date: valid_date, monthly_deduction: BigDecimal(0)}
                        else
                          MedicalRecord.create!(user_id: self.user_id, participate: true, participate_begin: valid_date, creator_id: operator_id)
                          {participate: 'participated', valid_date: nil, to_status: nil, participate_date: valid_date, monthly_deduction: BigDecimal('50')}
                        end
                      else
                        {}
                      end
      self.update(update_params.merge(operator_id: operator_id))
    end
  end


  def self.detail_by_id(id)
    MedicalInsuranceParticipator.includes(:user).find(id)
  end

  def self.detail_by_ids(ids)
    data = MedicalInsuranceParticipator.where(user_id: ids)
    absence_user_ids = ids.map(&:to_i) - MedicalInsuranceParticipator.where(user_id: ids).pluck(:user_id)
    return {
        data: data,
        absence_user_ids: absence_user_ids,
    }
  end

  def self.field_options
    user_query = self.joins(user: [:position, :department])
    positions = Position.where(id: user_query.map{|record| record.user.position_id}).as_json
    departments = Department.where(id: user_query.map{|record| record.user.department_id}).as_json
    grades = [
        {key: 1, chinese_name: 1, english_name: 1, simple_chinese_name: 1},
        {key: 2, chinese_name: 2, english_name: 2, simple_chinese_name: 2},
        {key: 3, chinese_name: 3, english_name: 3, simple_chinese_name: 3},
        {key: 4, chinese_name: 4, english_name: 4, simple_chinese_name: 4},
        {key: 5, chinese_name: 5, english_name: 5, simple_chinese_name: 5}
    ]
    medical_templates = MedicalTemplate.where(id: MedicalTemplateSetting.first.sections.pluck('current_template_id').without('nil'))
    return {
        positions: positions,
        departments: departments,
        grades: grades,
        participate: ['medical_insurance_participator.enum_participate.participated', 'medical_insurance_participator.enum_participate.not_participated'],
        medical_templates: medical_templates,
    }
  end

  def get_json_data
    data = self.as_json(include: { user: { include: [:department, :position] } })
    # 获取列表页 "入职日期"列
    data['date_of_employment'] = User.find(self['user_id'])
                                     .profile
                                     .data['position_information']['field_values']['date_of_employment']
    if data['participate'] == 'participated'
      data['medical_template'] = MedicalTemplate.find(self.medical_template_id) rescue nil
    end
    data
  end

  scope :by_employee_no, lambda { |empoid|
    where(users: {empoid: empoid})
  }

  scope :by_department_id, lambda { |department_id|
    where(users: {department_id: department_id})
  }

  scope :by_position_id, lambda { |position_id|
    where(users: {position_id: position_id})
  }

  scope :by_employee_grade, lambda { |grade|
    where(users: {grade: grade})
  }

  scope :by_participate, lambda { |participate|
    where(participate: participate)
  }

  scope :by_medical_template_id, lambda { |template_id|
    grade = MedicalTemplateSetting.first.sections.select{|hash| template_id.map(&:to_i).include? hash['current_template_id']}.map{|hash| hash['employee_grade']}
    where(participate: :participated).where(users: {grade: grade})
  }

  scope :by_monthly_deduction, lambda { |amount|
    where(monthly_deduction: amount)
  }

end
