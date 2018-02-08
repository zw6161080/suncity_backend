# == Schema Information
#
# Table name: appraisal_participators
#
#  id                                  :integer          not null, primary key
#  appraisal_id                        :integer
#  user_id                             :integer
#  department_id                       :integer
#  appraisal_grade                     :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  location_id                         :integer
#  appraisal_department_setting_id     :integer
#  appraisal_employee_setting_id       :integer
#  appraisal_group                     :string
#  appraisal_questionnaire_template_id :integer
#  departmental_appraisal_group        :string
#
# Indexes
#
#  index_appraisal_participators_on_appraisal_employee_setting_id  (appraisal_employee_setting_id)
#  index_appraisal_participators_on_appraisal_id                   (appraisal_id)
#  index_appraisal_participators_on_department_id                  (department_id)
#  index_appraisal_participators_on_location_id                    (location_id)
#  index_appraisal_participators_on_user_id                        (user_id)
#  index_on_appraisal_participator_on_department_setting           (appraisal_department_setting_id)
#
# Foreign Keys
#
#  fk_rails_34d2d0bf6a  (department_id => departments.id)
#  fk_rails_3eff08723e  (user_id => users.id)
#  fk_rails_8238958017  (appraisal_employee_setting_id => appraisal_employee_settings.id)
#  fk_rails_8313ee0ea4  (appraisal_id => appraisals.id)
#  fk_rails_9ec7b786bf  (appraisal_department_setting_id => appraisal_department_settings.id)
#  fk_rails_c8f42642ba  (location_id => locations.id)
#

class AppraisalParticipator < ApplicationRecord
  include StatementAble

  belongs_to :appraisal
  belongs_to :user
  belongs_to :assessor, :class_name => 'User'
  belongs_to :department
  belongs_to :location
  belongs_to :appraisal_department_setting
  belongs_to :appraisal_employee_setting

  has_many :appraisal_participators, :through => :assess_relationships
  has_many :assess_relationships, dependent: :destroy
  has_many :assessors, :through => :assess_relationships

  has_many :appraisal_participators, :through => :candidate_relationships
  has_many :candidate_relationships, dependent: :destroy
  has_many :candidate_participators, :through => :candidate_relationships

  has_many :appraisal_questionnaires, dependent: :destroy

  has_one :appraisal_report, dependent: :destroy


  # 属性持久化到自身 (评核模板id 分组 部门内层级 部门内分组)
  def regularize_setting
    appraisal_group = self.grade_to_group
    group_id = AppraisalEmployeeSetting.find_by(user_id: self.user.id).appraisal_group_id
    departmental_appraisal_group = group_id ? AppraisalGroup.find(group_id).name : '不分组'
    appraisal_template_id = self.appraisal_department_setting.group_to_questionnaire_template_id(appraisal_group)
    self.update(appraisal_group: appraisal_group,
                departmental_appraisal_group: departmental_appraisal_group,
                appraisal_questionnaire_template_id: appraisal_template_id)
  end


  def get_average_score(appraisal_questionnaires)
    mean = appraisal_questionnaires.collect(&:final_score).reduce(:+).to_f / appraisal_questionnaires.size
    mean.nan? ? 0 : mean
  end

  def generate_appraisal_report_overall_score
    aqs = self.appraisal_questionnaires
    # 计算单张问卷分数
    aqs.each {|aq| aq.count_questionnaire_score}
    # 计算各类问卷平均分
    aqs_of_superior = aqs.where(assess_type: 'superior_assess')
    aqs_of_colleague = aqs.where(assess_type: 'colleague_assess')
    aqs_of_subordinate = aqs.where(assess_type: 'subordinate_assess')
    aqs_of_self = aqs.where(assess_type: 'self_assess')
    score_of_self = get_average_score(aqs_of_self)
    score_of_superior = get_average_score(aqs_of_superior)
    score_of_colleague = get_average_score(aqs_of_colleague)
    score_of_subordinate = get_average_score(aqs_of_subordinate)
    overall_score = (score_of_self + score_of_superior + score_of_colleague + score_of_subordinate) / 4

    AppraisalReport.create(appraisal_id: self.appraisal_id,
                           appraisal_participator_id: self.id,
                           appraisal_group: self.appraisal_group,
                           overall_score: overall_score.to_s,
                           superior_score: score_of_superior.to_s,
                           colleague_score: score_of_colleague.to_s,
                           subordinate_score: score_of_subordinate.to_s,
                           self_score: score_of_self.to_s)
  end

  def grade_to_group
    basic_setting = AppraisalBasicSetting.first
    case self.user.grade.to_i
      when *basic_setting.group_A.map {|grade| grade.to_i} then
        'A'
      when *basic_setting.group_B.map {|grade| grade.to_i} then
        'B'
      when *basic_setting.group_C.map {|grade| grade.to_i} then
        'C'
      when *basic_setting.group_D.map {|grade| grade.to_i} then
        'D'
      when *basic_setting.group_E.map {|grade| grade.to_i} then
        'E'
      else
        nil
    end
  end

  # 创建评核候选人
  def create_candidate_participators
    # 清理原有关系
    self.candidate_relationships.destroy_all
    candidates_of_superior = self.get_superior_or_subordinate_candidates('superior')
    candidates_of_colleague = self.get_colleague_candidates
    candidates_of_subordinate = self.get_superior_or_subordinate_candidates('subordinate')
    self.create_candidate_relationships(candidates_of_superior, 'superior_assess')
    self.create_candidate_relationships(candidates_of_colleague, 'colleague_assess')
    self.create_candidate_relationships(candidates_of_subordinate, 'subordinate_assess')
  end

  # 创建评核人
  def create_assess_participators
    # 初始化 部门设定 & 评核人集合
    department_setting = self.appraisal_department_setting
    candidates_of_colleague = self.get_colleague_candidates
    assess_of_superior = self.get_superior_or_subordinate_candidates('superior')
    assess_of_subordinate = self.get_superior_or_subordinate_candidates('subordinate')
    # 同事评核人
    # (仅在组内 & 全部门内) -> 次数
    assess_of_colleague = candidates_of_colleague.sample(department_setting.appraisal_times_collegue || 0)
    # 上司评核人
    # 全部上司 & (部分上司 -> 次数)
    if department_setting.appraisal_mode_superior == 'assessed_by_part_of_the_superiors'
      assess_of_superior = assess_of_superior.sample(department_setting.appraisal_times_superior || 0)
    end
    # 下属评核人
    # 全部上司 & (部分上司 -> 次数)
    if department_setting.appraisal_mode_subordinate == 'assessed_by_part_of_the_superiors'
      assess_of_subordinate = assess_of_subordinate.sample(department_setting.appraisal_times_subordinate || 0)
    end
    # 清理原有评核关系
    self.assess_relationships.destroy_all
    # 创建新的评核关系
    self.create_assess_relationships(assess_of_superior, 'superior_assess')
    self.create_assess_relationships(assess_of_colleague, 'colleague_assess')
    self.create_assess_relationships(assess_of_subordinate, 'subordinate_assess')
    self.assess_relationships.create({
                                         appraisal_id: self.appraisal_id,
                                         appraisal_participator_id: self.id,
                                         assessor_id: self.user_id,
                                         assess_type: 'self_assess'
                                     })
  end

  # 创建评核候选关系 candidate_relationship
  def create_candidate_relationships(candidates, assess_type)
    candidates.each do |candidate|
      self.candidate_relationships.create({
                                              appraisal_id: self.appraisal_id,
                                              appraisal_participator_id: self.id,
                                              candidate_participator_id: candidate.id,
                                              assess_type: assess_type
                                          })
    end
  end

  # 创建评核关系 assess_relationship
  def create_assess_relationships(assessors, assess_type)
    assessors.each do |assessor|
      self.assess_relationships.create({
                                           appraisal_id: self.appraisal_id,
                                           appraisal_participator_id: self.id,
                                           assessor_id: assessor.user_id,
                                           assess_type: assess_type
                                       })
    end
  end

  def get_colleague_candidates
    return [] unless self.appraisal_employee_setting.level_in_department
                     # .includes(:appraisal_employee_setting, :appraisal_department_setting)
    candidates = self.appraisal.appraisal_participators
                     .joins(:appraisal_employee_setting, :appraisal_department_setting)
                     .where(appraisal_id: self.appraisal_id)
                     .where(location_id: self.location_id)
                     .where(department_id: self.department_id)
                     .where(:appraisal_employee_settings => { level_in_department: self.appraisal_employee_setting.level_in_department })
                     .where.not(user_id: self.user_id)
    if self.appraisal_department_setting.appraisal_mode_collegue == 'group_only'
      # if self.appraisal_department_setting.whether_group_inside
      result = candidates.where(:appraisal_employee_settings => { appraisal_group_id: self.appraisal_employee_setting.appraisal_group_id })
    else
      result = candidates
    end
    result
  end

  def get_superior_or_subordinate_candidates(type)
    # query = AppraisalParticipator.includes(:appraisal_employee_setting)
    level_in_department = self.appraisal_employee_setting.level_in_department
    return [] unless level_in_department
    appraisal_grade = type == 'superior' ? level_in_department - 1 : level_in_department + 1
    # 筛选同场馆、同部门的评核人员
                     # .includes(:appraisal_employee_setting, :appraisal_department_setting)
    candidates = self.appraisal.appraisal_participators
                     .joins(:appraisal_employee_setting, :appraisal_department_setting)
                     .where(appraisal_id: self.appraisal_id)
                     .where(location_id: self.location_id)
                     .where(department_id: self.department_id)
                     .where.not(user_id: self.user_id)
    # 判断是否分组
    if self.appraisal_department_setting.whether_group_inside
      # 部门内分组相同 => 确定为候选人
      result = candidates.where(:appraisal_employee_settings => { appraisal_group_id: self.appraisal_employee_setting.appraisal_group_id })
    else
      result = candidates
    end
    # 可以跨层级评核
    if self.appraisal_department_setting.can_across_appraisal_grade
      # 可以跨层级 上司候选人 层级大于自身层级
      if type == 'superior'
        result = result.where('appraisal_employee_settings.level_in_department <= ?', appraisal_grade)
      elsif type == 'subordinate'
      # 可以跨层级 下属候选人 层级小于自身层级
        result = result.where('appraisal_employee_settings.level_in_department >= ?', appraisal_grade)
      else
        result = result.where(:appraisal_employee_settings => { level_in_department: 999 })
      end
    else
      # 不可以跨层级
      result = result.where(:appraisal_employee_settings => { level_in_department: appraisal_grade })
    end
    result
  end

  def self.options
    query = self.left_outer_joins(user: [:location, :department, :position])
    location = query.select('locations.*').distinct.as_json
    department = query.select('departments.*').distinct.as_json
    position = query.select('positions.*').distinct.as_json
    grade = [
        {key: 1, chinese_name: 1, english_name: 1, simple_chinese_name: 1},
        {key: 2, chinese_name: 2, english_name: 2, simple_chinese_name: 2},
        {key: 3, chinese_name: 3, english_name: 3, simple_chinese_name: 3},
        {key: 4, chinese_name: 4, english_name: 4, simple_chinese_name: 4},
        {key: 5, chinese_name: 5, english_name: 5, simple_chinese_name: 5},
    ]
    division_of_job = [
        {key: 'front_office',
         chinese_name: I18n.t('appraisal_participator.division_of_job.front_office', locale: :'zh-HK'),
         english_name: I18n.t('appraisal_participator.division_of_job.front_office', locale: :en),
         simple_chinese_name: I18n.t('appraisal_participator.division_of_job.front_office', locale: :'zh-CN')},
        {key: 'back_office',
         chinese_name: I18n.t('appraisal_participator.division_of_job.back_office', locale: :'zh-HK'),
         english_name: I18n.t('appraisal_participator.division_of_job.back_office', locale: :en),
         simple_chinese_name: I18n.t('appraisal_participator.division_of_job.back_office', locale: :'zh-CN')}
    ]
    {
        location: location,
        department: department,
        position: position,
        grade: grade,
        division_of_job: division_of_job
    }
  end

  def self.options_later
    query = self.left_outer_joins(user: [:location, :department, :position])
    location = query.select('locations.*').distinct.as_json
    department = query.select('departments.*').distinct.as_json
    position = query.select('positions.*').distinct.as_json
    grade = [
        {key: 1, chinese_name: 1, english_name: 1, simple_chinese_name: 1},
        {key: 2, chinese_name: 2, english_name: 2, simple_chinese_name: 2},
        {key: 3, chinese_name: 3, english_name: 3, simple_chinese_name: 3},
        {key: 4, chinese_name: 4, english_name: 4, simple_chinese_name: 4},
        {key: 5, chinese_name: 5, english_name: 5, simple_chinese_name: 5},
    ]
    division_of_job = {options: [
        {key: 'front_office',
         chinese_name: I18n.t('appraisal_participator.division_of_job.front_office', locale: :'zh-HK'),
         english_name: I18n.t('appraisal_participator.division_of_job.front_office', locale: :en),
         simple_chinese_name: I18n.t('appraisal_participator.division_of_job.front_office', locale: :'zh-CN')},
        {key: 'back_office',
         chinese_name: I18n.t('appraisal_participator.division_of_job.back_office', locale: :'zh-HK'),
         english_name: I18n.t('appraisal_participator.division_of_job.back_office', locale: :en),
         simple_chinese_name: I18n.t('appraisal_participator.division_of_job.back_office', locale: :'zh-CN')}
    ]}
    {
        location: location,
        department: department,
        position: position,
        grade: grade,
        division_of_job: division_of_job
    }
  end

  def filter_candidates_by_appraisal_group(appraisal_group_id)

  end

  scope :by_assess_others, -> (times, appraisal_id) {
    if times.to_i == 0
      where.not(users: {id: User.joins(:assess_relationships)
                                .where(:assess_relationships => { appraisal_id: appraisal_id })
                                .where.not(:assess_relationships => { assess_type: 'self_assess' }).ids})
    else
      joins(:appraisal => {:assess_relationships => :assessor})
          .group('appraisal_participators.id')
          .where.not(:assess_relationships => { assess_type: 'self_assess' })
          .where('assessors_assess_relationships.id = appraisal_participators.user_id')
          .having('count(assess_relationships.*) = (:time)::int', time: times)
    end
  }

  scope :by_employee_id, ->(empoid) {
    where(users: {empoid: empoid})
  }

  scope :by_employee_name, ->(name) {
    where('users.chinese_name = :name OR users.english_name = :name OR users.simple_chinese_name = :name', name: name)
  }
  scope :by_location, ->(location_id) {
    where(users: {location_id: location_id})
  }

  scope :by_department, ->(department_id) {
    where(users: {department_id: department_id})
  }

  scope :by_position, ->(position_id) {
    where(users: {position_id: position_id})
  }

  scope :by_grade, ->(grade) {
    where(users: {grade: grade})
  }

  scope :by_division_of_job, ->(division_of_job) {
    if division_of_job && (division_of_job.is_a? Array)
      where("profiles.data -> 'position_information' -> 'field_values' -> 'division_of_job' ?| array["+ division_of_job.map {|item| "'#{item}'"}.join(',') +"]")
    elsif division_of_job
      where("profiles.data #>> '{position_information, field_values, division_of_job}' = :division_of_job", division_of_job: division_of_job)
    end
  }

  scope :by_date_of_employment, ->(date_of_employment) {
    from = Time.zone.parse(date_of_employment[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_of_employment[:end]).end_of_day rescue nil
    if from && to
      includes(user: :profile)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes(user: :profile)
      .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes(user: :profile)
      .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :empoid                then order("users.empoid #{sort_direction}")
      when :name                  then order("users.chinese_name #{sort_direction}")
      when :employee_id           then order("users.empoid #{sort_direction}")
      when :employee_name         then order("users.chinese_name #{sort_direction}")
      when :location              then order("users.location_id #{sort_direction}")
      when :department            then order("users.department_id #{sort_direction}")
      when :position              then order("users.position_id #{sort_direction}")
      when :grade                 then order("users.grade #{sort_direction}")
      when :assess_others         then
        if sort_direction == :desc
          joins(:appraisal => {:assess_relationships => :assessor})
              .group('appraisal_participators.id')
              .where.not(:assess_relationships => {assess_type: 'self_assess'})
              .where('assessors_assess_relationships.id = appraisal_participators.user_id')
              .select('appraisal_participators.*, count(assess_relationships.*) as count_number')
              .order('count_number DESC NULLS LAST')
        else
          joins(:appraisal => {:assess_relationships => :assessor})
              .group('appraisal_participators.id')
              .where.not(:assess_relationships => {assess_type: 'self_assess'})
              .where('assessors_assess_relationships.id = appraisal_participators.user_id')
              .select('appraisal_participators.*, count(assess_relationships.*) as count_number')
              .order('count_number NULLS FIRST')
        end
      when :division_of_job       then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, division_of_job}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, division_of_job}' ")
        end
      when :date_of_employment    then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
        end
      else
        order(sort_column => sort_direction)
    end
  }

end
