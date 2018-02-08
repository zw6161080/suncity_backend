# == Schema Information
#
# Table name: appraisal_reports
#
#  id                        :integer          not null, primary key
#  appraisal_id              :integer
#  appraisal_participator_id :integer
#  overall_score             :decimal(5, 2)
#  superior_score            :decimal(5, 2)
#  colleague_score           :decimal(5, 2)
#  subordinate_score         :decimal(5, 2)
#  self_score                :decimal(5, 2)
#  report_detail             :jsonb            not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  appraisal_group           :string
#
# Indexes
#
#  index_appraisal_reports_on_appraisal_id               (appraisal_id)
#  index_appraisal_reports_on_appraisal_participator_id  (appraisal_participator_id)
#
# Foreign Keys
#
#  fk_rails_d85462d148  (appraisal_id => appraisals.id)
#  fk_rails_f28fbbf99f  (appraisal_participator_id => appraisal_participators.id)
#

class AppraisalReport < ApplicationRecord

  include StatementAble

  belongs_to :appraisal
  belongs_to :appraisal_participator


  # 平均值
  def self.get_average_value(scores)
    total = scores.size
    count = total if (total > 0)
    scores.reduce(:+).to_f / (count || 1)
  end

  # 标准差
  def self.get_standard_deviation(array)
    # 平均值
    mean = self.get_average_value(array)
    # 样本方差
    sum = array.inject(0) {|accum, i| accum + (i - mean) ** 2}
    total = array.length
    sample_variance = sum / (((total > 0) ? total : 2) - 1).to_f
    # 标准差
    Math.sqrt(sample_variance)
  end

  # 标准分
  def self.get_standard_score(array, score)
    # 平均值
    mean = self.get_average_value(array)
    # 标准差
    sd = self.get_standard_deviation(array)
    # 标准分
    standard_score = (score - mean) / (sd > 0 ? sd : 1)
    standard_score
  end

  # 百分等级
  def self.get_percentage_grade(array, score)
    # TODO 计算百分等级
    percentage_grade = 0
    percentage_grade
  end

  def generate_detail_report
    qs_template = QuestionnaireTemplate.find(self.appraisal_participator.appraisal_questionnaire_template_id)
    # intial report_detail
    report_detail = {}
    report_detail['employee_relative_position_distribution'] = {}
    report_detail['employee_relative_position_distribution']['company'] = {}
    report_detail['employee_relative_position_distribution']['department'] = {}
    report_detail['employee_in_group_strengths_and_weaknesses'] = []
    # set appraisal_questionnaires
    aqs = self.appraisal_participator.appraisal_questionnaires
    aqs_of_superior = aqs.where(assess_type: 'superior_assess')
    aqs_of_colleague = aqs.where(assess_type: 'colleague_assess')
    aqs_of_subordinate = aqs.where(assess_type: 'subordinate_assess')
    aqs_of_self = aqs.find_by(assess_type: 'self_assess')
    report_detail['superior_count'] = aqs_of_superior.count
    report_detail['colleague_count'] = aqs_of_colleague.count
    report_detail['subordinate_count'] = aqs_of_subordinate.count
    report_detail['assessor_count'] = aqs_of_superior.count + aqs_of_colleague.count + aqs_of_subordinate.count + 1

    # 员工相对位置分布
    ## 公司内同组报告
    reports_of_company = AppraisalReport.where(appraisal_id: self.appraisal_id).where(appraisal_group: self.appraisal_group)
    scores_of_company = reports_of_company.collect(&:overall_score)
    report_detail['employee_relative_position_distribution']['company']['average_score'] = AppraisalReport.get_average_value(scores_of_company)
    report_detail['employee_relative_position_distribution']['company']['standard_deviation'] = AppraisalReport.get_standard_deviation(scores_of_company)
    report_detail['employee_relative_position_distribution']['company']['standard_score'] = AppraisalReport.get_standard_score(scores_of_company, self.overall_score)
    report_detail['employee_relative_position_distribution']['company']['percentage_grade'] = AppraisalReport.get_percentage_grade(scores_of_company, self.overall_score)
    ## 部门内同组报告
    reports_of_department = AppraisalParticipator.where(appraisal_id: self.appraisal_id)
                              .where(location_id: self.appraisal_participator.location_id)
                              .where(department_id: self.appraisal_participator.department_id)
                              .where(appraisal_group: self.appraisal_group)
                              .collect(&:appraisal_report)
    scores_of_department = reports_of_department.collect(&:overall_score)
    report_detail['employee_relative_position_distribution']['department']['average_score'] = AppraisalReport.get_average_value(scores_of_department)
    report_detail['employee_relative_position_distribution']['department']['standard_deviation'] = AppraisalReport.get_standard_deviation(scores_of_department)
    report_detail['employee_relative_position_distribution']['department']['standard_score'] = AppraisalReport.get_standard_score(scores_of_department, self.overall_score)
    report_detail['employee_relative_position_distribution']['department']['percentage_grade'] = AppraisalReport.get_percentage_grade(scores_of_department, self.overall_score)

    # 員工在團隊之優劣勢
    employee_in_group_strengths_and_weaknesses = []
    questionnaires_of_employee = aqs.collect(&:questionnaire_id)
    questionnaires_of_department = []
    appraisal_participators = AppraisalParticipator.where(appraisal_id: self.appraisal_id)
                                .where(location_id: self.appraisal_participator.location_id)
                                .where(department_id: self.appraisal_participator.department_id)
                                .where(appraisal_group: self.appraisal_group)
    appraisal_questionnaires_of_department = []
    appraisal_participators.each do |ap|
      ap.appraisal_questionnaires.each { |aq| appraisal_questionnaires_of_department << aq}
    end
    questionnaires_of_self = self.appraisal_participator.appraisal_questionnaires.collect(&:questionnaire)
    qs_template.matrix_single_choice_questions.each do |mscq|
      personal_average_value = AppraisalReport.get_average_value(MatrixSingleChoiceQuestion
                                                                   .where(questionnaire_id: questionnaires_of_self.collect(&:id))
                                                                   .where(order_no: mscq.order_no).collect(&:score_of_question))
      departmental_average_value = AppraisalReport.get_average_value(MatrixSingleChoiceQuestion
                                                                       .where(questionnaire_id: appraisal_questionnaires_of_department.collect(&:questionnaire_id))
                                                                       .where(order_no: mscq.order_no).collect(&:score_of_question))
      employee_in_group_strengths_and_weaknesses << {
        question_title: mscq.title,
        personal_average_value: personal_average_value,
        departmental_average_value: departmental_average_value
      }
    end
    report_detail['employee_in_group_strengths_and_weaknesses'] = employee_in_group_strengths_and_weaknesses

    # 差异分析
    questionnaires_of_superior = aqs_of_superior.collect(&:questionnaire)
    questionnaires_of_colleague = aqs_of_colleague.collect(&:questionnaire)
    questionnaires_of_subordinate = aqs_of_subordinate.collect(&:questionnaire)
    questionnaires_of_self = aqs_of_self.questionnaire
    # questionnaires_of_employee
    ## 大题
    differences_in_analysis = []
    qs_template.matrix_single_choice_questions.each do |mscq|
      differences_in_analysis << {
        title: mscq.title,
        superior_assess: AppraisalReport.get_differences_in_analysis(questionnaires_of_superior, mscq.order_no),
        colleague_assess: AppraisalReport.get_differences_in_analysis(questionnaires_of_colleague, mscq.order_no),
        subordinate_assess: AppraisalReport.get_differences_in_analysis(questionnaires_of_subordinate, mscq.order_no),
        self_assess: AppraisalReport.get_differences_in_analysis([questionnaires_of_self], mscq.order_no),
        # self_assess: questionnaires_of_self.matrix_single_choice_questions.find_by(order_no: mscq.order_no).score_of_question
      }
    end
    report_detail['differences_in_analysis'] = differences_in_analysis

    ## 小题
    differences_in_analysis_items = []
    qs_template.matrix_single_choice_questions.each do |mscq|
      question = {}
      items = []
      mscq.matrix_single_choice_items.each do |mscq_item|
        items << {
          superior_assess: AppraisalReport.get_differences_in_analysis_of_item(aqs_of_superior, mscq.order_no, mscq_item.item_no),
          colleague_assess: AppraisalReport.get_differences_in_analysis_of_item(aqs_of_colleague, mscq.order_no, mscq_item.item_no),
          subordinate_assess: AppraisalReport.get_differences_in_analysis_of_item(aqs_of_subordinate, mscq.order_no, mscq_item.item_no),
          self_assess: AppraisalReport.get_differences_in_analysis_of_item([aqs_of_self], mscq.order_no, mscq_item.item_no)
        }
      end
      question['items'] = items
      differences_in_analysis_items << question
    end
    report_detail['differences_in_analysis_items'] = differences_in_analysis_items

    # 自我意识强弱比较
    self_cognition = []
    questionnaire_of_others = aqs.collect(&:questionnaire)
    qs_template.matrix_single_choice_questions.each do |mscq|
      self_cognition << {
        title: mscq.title,
        self_assess: AppraisalReport.get_differences_in_analysis([questionnaires_of_self], mscq.order_no),
        others_assess: AppraisalReport.get_differences_in_analysis(questionnaire_of_others, mscq.order_no),
      }
    end
    report_detail['self_cognition'] = self_cognition

    # update report
    self.update(report_detail: report_detail)
  end

  def self.get_differences_in_analysis(questionnaires, order_no)
    AppraisalReport.get_average_value(MatrixSingleChoiceQuestion
                                        .where(questionnaire_id: questionnaires.collect(&:id))
                                        .where(order_no: order_no).collect(&:score_of_question))
  end

  def self.get_differences_in_analysis_of_item(questionnaires, order_no, item_no)
    questionnaire_ids = questionnaires.collect(&:questionnaire_id)
    mscq = MatrixSingleChoiceQuestion
                  .where(questionnaire_id: questionnaire_ids)
                  .where(order_no: order_no)
    mscqs_ids = mscq.collect(&:id)
    AppraisalReport.get_average_value(MatrixSingleChoiceItem
                                        .where(matrix_single_choice_question_id: mscqs_ids)
                                        .where(item_no: item_no)
                                        .collect(&:score))
  end

  def self.joined_query(param_id = nil)
    self.left_outer_joins(
        [
        ].concat(extra_joined_association_names)
    )
  end

  class << self
    def department_options
      Department.where(id: self.joins(:appraisal_participator => :user).select('users.department_id'))
    end

    def location_options
      Location.where(id: self.joins(:appraisal_participator => :user).select('users.location_id'))
    end

    def position_options
      Position.where(id: self.joins(:appraisal_participator => :user).select('users.position_id'))
    end

    def grade_options
      keys = self.joins(:appraisal_participator => :user).select('users.grade').map{|item| item['grade']}
      Config.get_option_from_selects('grade', keys)
    end

    def department_record_options
      Department.where(id: self.joins(:appraisal_employee_setting => :user).select('users.department_id'))
    end

    def location_record_options
      Location.where(id: self.joins(:appraisal_employee_setting  => :user).select('users.location_id'))
    end

    def position_record_options
      Position.where(id: self.joins(:appraisal_employee_setting  => :user).select('users.position_id'))
    end

    def grade_record_options
      keys = self.joins(:appraisal_participator => :user).select('users.grade').map{|item| item['grade']}
      Config.get_option_from_selects('grade', keys)
    end
  end

  scope :by_employee_id, -> (empoid) {
    where(:users => { empoid: empoid }) if empoid
  }

  scope :by_name, -> (name) {
    where(:appraisal_participators => {user_id: User.where('chinese_name = :name OR english_name = :name OR simple_chinese_name = :name', name: name).select(:id)}) if name
  }

  scope :by_location, -> (location) {
    where(:users => { location_id: location }) if location
  }

  scope :by_department, -> (department) {
    where(:users => { department_id: department }) if department
  }

  scope :by_position, -> (position) {
    where(:users => { position_id: position }) if position
  }

  scope :by_grade, -> (grade) {
    where(:users => { grade: grade }) if grade
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
      includes({:appraisal_participator => {:user => :profile} })
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes({:appraisal_participator => {:user => :profile} }).where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes({:appraisal_participator => {:user => :profile} }).where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :by_appraisal_total_count, -> (appraisal_total_count) {
    joins(:appraisal_participator => :assess_relationships)
        .group('appraisal_reports.id, users.empoid')
        .having('(count(assess_relationships.*)-1) = (:time)::int', time: appraisal_total_count) if appraisal_total_count
  }

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :empoid ,:employee_id               then order("users.empoid #{sort_direction}")
      when :name                  then order("users.chinese_name #{sort_direction}")
      when :location              then order("users.location_id #{sort_direction}")
      when :department            then order("users.department_id #{sort_direction}")
      when :position              then order("users.position_id #{sort_direction}")
      when :grade                 then order("users.grade #{sort_direction}")
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
      when :appraisal_total_count     then
        if sort_direction == :desc
          joins(:appraisal_participator => :assess_relationships)
              .group('appraisal_reports.id')
              .select('appraisal_reports.*, count(assess_relationships.*) as count_number')
              .order('count_number DESC')
        else
          joins(:appraisal_participator => :assess_relationships)
              .group('appraisal_reports.id')
              .select('appraisal_reports.*, count(assess_relationships.*) as count_number')
              .order('count_number')
        end
      else
        order(sort_column => sort_direction)
    end
  }



end
