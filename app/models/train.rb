# coding: utf-8
# == Schema Information
#
# Table name: trains
#
#  id                                                     :integer          not null, primary key
#  train_template_id                                      :integer
#  chinese_name                                           :string
#  english_name                                           :string
#  train_date_begin                                       :datetime
#  train_date_end                                         :datetime
#  train_place                                            :string
#  train_cost                                             :decimal(15, 2)
#  registration_date_begin                                :datetime
#  registration_date_end                                  :datetime
#  registration_method                                    :integer
#  limit_number                                           :integer
#  grade                                                  :jsonb
#  division_of_job                                        :jsonb
#  comment                                                :string
#  status                                                 :integer
#  created_at                                             :datetime         not null
#  updated_at                                             :datetime         not null
#  simple_chinese_name                                    :string
#  train_number                                           :string
#  satisfaction_percentage                                :decimal(10, 2)
#  by_invited                                             :integer          default([]), is an Array
#  train_template_chinese_name                            :string
#  train_template_english_name                            :string
#  train_template_simple_chinese_name                     :string
#  course_number                                          :string
#  teaching_form                                          :string
#  train_template_type_id                                 :integer
#  training_credits                                       :decimal(15, 2)   default(0.0)
#  online_or_offline_training                             :integer
#  train_template_limit_number                            :integer
#  course_total_time                                      :decimal(15, 2)
#  course_total_count                                     :decimal(15, 2)
#  trainer                                                :string
#  language_of_training                                   :string
#  place_of_training                                      :string
#  contact_person_of_training                             :string
#  course_series                                          :string
#  course_certificate                                     :string
#  introduction_of_trainee                                :string
#  introduction_of_course                                 :string
#  goal_of_learning                                       :string
#  content_of_course                                      :string
#  goal_of_course                                         :string
#  assessment_method                                      :integer
#  test_scores_not_less_than                              :decimal(15, 2)
#  exam_format                                            :integer
#  exam_template_id                                       :integer
#  comprehensive_attendance_not_less_than                 :decimal(15, 2)
#  comprehensive_attendance_and_test_scores_not_less_than :decimal(15, 2)
#  test_scores_percentage                                 :decimal(15, 2)
#  train_template_notice                                  :string
#  train_template_comment                                 :string
#
# Indexes
#
#  index_trains_on_train_template_id  (train_template_id)
#

class Train < ApplicationRecord
  include StatementAble
  include TrainValidators
  validates :chinese_name, :english_name, :simple_chinese_name, :train_number, :train_date_begin, :train_date_end, :train_cost,
            :registration_date_begin, :registration_date_end, :registration_method, :limit_number, :status, presence: true

  validates_with TrainWithRightValueValidator

  has_and_belongs_to_many :locations
  has_and_belongs_to_many :departments
  has_and_belongs_to_many :positions

  has_and_belongs_to_many :users
  has_many :titles
  has_many :train_classes
  has_many :entry_lists
  has_many :final_lists
  has_many :sign_lists
  has_many :student_evaluations
  belongs_to :train_template_type

  has_many :online_materials, as: :attachable , dependent: :destroy
  has_many :attend_attachments, as: :attachable
  belongs_to :exam_template, class_name: 'QuestionnaireTemplate', foreign_key: 'exam_template_id'
  after_update :update_status, if: :can_call?
  enum registration_method: {by_employee: 0, by_department: 1, by_employee_and_department: 2}
  enum status: {not_published: 0, has_been_published: 1, signing_up: 2, registration_ends: 3, training: 4, completed: 5, cancelled: 6}
  enum online_or_offline_training: {online_training: 0, offline_training: 1}
  enum assessment_method: {by_attendance_rate: 0, by_test_scores:1, by_both: 2}
  enum exam_format: {online: 0, offline: 1}

  def can_call?
    !(%w(not_published training completed cancelled).include?(self.status))
  end

  def update_status
    self.has_been_published unless self.status == 'has_been_published'
    self.execute_signing_up  unless self.status == 'signing_up'
    self.execute_registration_ends  unless self.status == 'registration_ends'
  end


  def the_total_number_of_participants
    #满足筛选条件的员工
    user_satisfying_the_request = self.user_satisfying_the_request
    #被邀请的员工
    user_by_invited = self.user_by_invited
    #被减数
    users_in_first_place = User.where(id: (user_satisfying_the_request.select(:id).distinct&.map { |item| item['id'] } + user_by_invited.map { |item| item['id'] }))
    #减数
    users_in_second_place = users_in_first_place.select { |item|
      !item.trains.where(train_template_id: self.train_template_id).empty?
    }
    #结果
    User.where(id: (users_in_first_place.select(:id).distinct&.map { |item| item['id'] } - users_in_second_place.map { |item| item['id'] }))
  end


  #满足筛选条件的员工
  def user_satisfying_the_request
    User.join_department_position_profile
        .by_location_id(self.locations.select(:id).distinct&.map { |item| item['id'] })
        .by_department_id(self.departments.select(:id).distinct&.map { |item| item['id'] })
        .by_position_id(self.positions.select(:id).distinct&.map { |item| item['id'] })
        .by_grade(self.grade)
        .by_division_of_job(self.division_of_job)
  end

  #被邀请的员工
  def user_by_invited
    entry_lists = self.entry_lists.select(:user_id).distinct
    if entry_lists.empty?
      []
    else
      User.where(id: entry_lists.map { |item| item['user_id'] })
    end
  end

  #可以参加培训的员工
  def can_join_train
    #满足筛选条件的员工
    user_satisfying_the_request = self.user_satisfying_the_request
    #被邀请的员工
    user_by_invited = self.user_by_invited
    #被减数
    User.where(id: (user_satisfying_the_request.select(:id).distinct&.map { |item| item['id'] } + user_by_invited.map { |item| item['id'] }))
  end
  #可以参加培训的员工的主管
  def  heads
    department_group_users = Role.find_by(key: 'department_group')&.users
    should_send_department_ids = self.can_join_train.pluck(:department_id)&.compact&.uniq
    department_group_users&.where(department_id: should_send_department_ids)&.pluck(:id)
    # self.can_join_train.joins(:department).pluck("departments.head_id")
  end


  def introduction
    entry_lists_count = self.entry_lists.where.not(registration_status:'cancel_the_registration').count
    final_lists_count = self.final_lists.count
    if entry_lists_count != 0
      average_cost_of_entry = self.train_cost / entry_lists_count
    else
      average_cost_of_entry = 0
    end
    if final_lists_count != 0
      average_cost_of_final = self.train_cost / final_lists_count
    else
      average_cost_of_final = 0
    end

    the_total_number_of_participants = self.the_total_number_of_participants.count
    self.as_json(include: [:positions, :departments, :locations, :titles, :exam_template, :train_template_type,{attend_attachments: {include: :creator}}, {train_classes: {include: :title}}], methods: :train_template).merge ({
        entry_lists_count: self.entry_lists.where.not(registration_status:'cancel_the_registration').count,
        final_lists_count: self.final_lists.count,
        average_cost_of_entry: average_cost_of_entry,
        average_cost_of_final: average_cost_of_final,
        the_total_number_of_participants: the_total_number_of_participants,
        locations_is_all: self.locations_is_all,
        departments_is_all: self.departments_is_all,
        positions_is_all: self.positions_is_all,
        grade_is_all: self.grade_is_all,
        division_of_job_is_all: self.division_of_job_is_all
    })
  end

  def train_template
    {
      chinese_name: self.train_template_chinese_name,
      english_name: self.train_template_english_name,
      simple_chinese_name: self.train_template_simple_chinese_name,
      course_number: self.course_number,
      teaching_form: self.teaching_form,
      train_template_type_id: self.train_template_type_id,
      train_template_type: self.train_template_type,
      training_credits: self.training_credits,
      online_or_offline_training: self.online_or_offline_training,
      limit_number: self.train_template_limit_number,
      course_total_time: self.course_total_time,
      course_total_count: self.course_total_count,
      trainer: self.trainer,
      language_of_training: self.language_of_training,
      place_of_training: self.place_of_training,
      contact_person_of_training: self.contact_person_of_training,
      course_series: self.course_series,
      course_certificate: self.course_certificate,
      introduction_of_trainee: self.introduction_of_trainee,
      introduction_of_course: self.introduction_of_course,
      goal_of_learning: self.goal_of_learning,
      content_of_course: self.content_of_course,
      goal_of_course: self.goal_of_course,
      assessment_method: self.assessment_method,
      test_scores_not_less_than: self.test_scores_not_less_than,
      exam_format: self.exam_format,
      exam_template_id: self.exam_template_id,
      exam_template: self.exam_template,
      attend_attachments: self.attend_attachments.as_json(include: :creator),
      comprehensive_attendance_not_less_than: self.comprehensive_attendance_not_less_than,
      comprehensive_attendance_and_test_scores_not_less_than: self.comprehensive_attendance_and_test_scores_not_less_than,
      test_scores_percentage: self.test_scores_percentage,
      notice: self.train_template_notice,
      comment: self.train_template_comment
    }
  end

  def locations_is_all
    self.locations.count == Location.count
  end

  def positions_is_all
    self.positions.count == Position.count
  end

  def departments_is_all
    self.departments.count == Department.count
  end

  def grade_is_all
    self.grade == Config.get(:selects).dig('grade.options').map{|hash| hash['key']}
  end

  def division_of_job_is_all
    self.division_of_job == Config.get(:selects).dig('division_of_job.options').map{|hash| hash['key']}
  end

  def entry_lists_count
    self.entry_lists.where.not(registration_status:'cancel_the_registration').count
  end

  def get_entry_lists
    self.entry_lists
  end


  def final_lists_count
    self.final_lists.count
  end


  def update_with_params(train_params, locations_params, positions_params, departments_params, titles_params, train_classes_params)
    result = nil
    ActiveRecord::Base.transaction do
      self.update!(train_params)
      if locations_params.is_a? Array
        unless locations_params.empty?
          self.locations.clear
          self.locations = Location.where(id: locations_params)
        end
      end
      if departments_params.is_a? Array
        unless departments_params.empty?
          self.departments.clear
          self.departments = Department.where(id: departments_params)
        end
      end
      if positions_params.is_a? Array
        unless positions_params.empty?
          self.positions.clear
          self.positions = Position.where(id: positions_params)
        end
      end
      if titles_params.is_a?(Array) && !titles_params&.empty? && train_classes_params.is_a?(Array) && !train_classes_params&.empty?
        self.titles.destroy_all
        self.train_classes.destroy_all
        titles_params.each do |item_params|
          title = self.titles.create!(item_params)
          title_classes = train_classes_params.select { |hash| hash['col'].to_i == title.col }
          # Classes Associations
          title_classes.each do |single_class_params|
            title.train_classes.create(single_class_params&.permit(*TrainClass.create_params).merge({train_id: self.id}))
          end if train_classes_params
        end if titles_params
      end
      result = self.id
    end
    result
  end

  def self.create_with_params(train_params, titles, classes, positions, departments, locations, users_by_invite, current_user_id, train_template)
    train = nil
    ActiveRecord::Base.transaction do
      # Self Model
      train = self.create!(train_params.merge({status: 'not_published'}))
      # Titles Associations
      titles.each do |item_params|
        title =train.titles.create!(item_params)
        title_classes = classes.select { |hash| hash['col'].to_i == title.col }
        # Classes Associations
        title_classes.each do |single_class_params|
          title.train_classes.create!(single_class_params&.permit(*TrainClass.create_params).merge({train_id: train.id}))
        end if title_classes
      end if titles
      positions.each do |position|
        train.positions << Position.find(position)
      end if positions
      departments.each do |department|
        train.departments << Department.find(department)
      end  if departments
      locations.each do |location|
        train.locations << Location.find(location)
      end if locations
      users_by_invite&.each do|user_id|
        EntryList.create_with_params(user_id, train.titles.first.id , 'by_invited', current_user_id , train.id)
      end
      train_template.attend_attachments.each do |attend_attachment|
        train.attend_attachments.create(attend_attachment.slice(*AttendAttachment.create_params + %w(creator_id)))
      end
      train_template.online_materials.each do |online_material|
        train.online_materials.create(online_material.slice(*OnlineMaterial.create_params + %w(creator_id)))
      end
      qt = QuestionnaireTemplate.copy(train_template.exam_template_id) if train_template.exam_template_id
      train.exam_template_id = qt.id if qt
      train.train_template_chinese_name = train_template.chinese_name
      train.train_template_english_name = train_template.english_name
      train.train_template_simple_chinese_name = train_template.simple_chinese_name
      train.train_template_type_id = train_template.train_template_type_id
      train.course_number = train_template.course_number
      train.teaching_form = train_template.teaching_form
      train.training_credits = train_template.training_credits
      train.online_or_offline_training = train_template.online_or_offline_training
      train.train_template_limit_number = train_template.limit_number
      train.course_total_time = train_template.course_total_time
      train.course_total_count = train_template.course_total_count
      train.trainer = train_template.trainer
      train.language_of_training = train_template.language_of_training
      train.place_of_training = train_template.place_of_training
      train.contact_person_of_training = train_template.contact_person_of_training
      train.course_series = train_template.course_series
      train.course_certificate = train_template.course_certificate
      train.introduction_of_trainee = train_template.introduction_of_trainee
      train.introduction_of_course = train_template.introduction_of_course
      train.goal_of_learning = train_template.goal_of_learning
      train.content_of_course = train_template.content_of_course
      train.goal_of_course = train_template.goal_of_course
      train.assessment_method = train_template.assessment_method
      train.test_scores_not_less_than = train_template.test_scores_not_less_than
      train.exam_format = train_template.exam_format
      train.comprehensive_attendance_not_less_than = train_template.comprehensive_attendance_not_less_than
      train.comprehensive_attendance_and_test_scores_not_less_than = train_template.comprehensive_attendance_and_test_scores_not_less_than
      train.test_scores_percentage = train_template.test_scores_percentage
      train.train_template_notice = train_template.notice
      train.train_template_comment = train_template.comment
      train.save!
    end
    train.try(:id)
  end

  def self.create_params
    super.collect { |item|
      item = {item => []} if %w(grade division_of_job).include? item
      item
    }
  end

  scope :by_order, lambda{|sort_column, sort_direction|
      order(sort_column => sort_direction)
  }


  scope :joins_train_template_and_train_template_type, lambda {
    joins(:train_template_type)
  }

  scope :left_outer_joins_entry_list_and_final_list, lambda {
    left_outer_joins(:entry_list, :final_list)
  }
  scope :by_train_date, lambda { |train_date_begin, train_date_end|
    if train_date_begin && train_date_end
      where(train_date_begin: train_date_begin...train_date_end).or(
          where(train_date_end: train_date_begin...train_date_end)
      )
    elsif train_date_begin
      where('train_date_end > :train_date_begin', train_date_begin: train_date_begin)
    elsif train_date_end
      where('train_date_begin < :train_date_end', train_date_end: train_date_end)
    end
  }

  scope :by_status, lambda { |status|
    where(status: status) if status
  }


  scope :by_registration_method, lambda { |registration_method|
    where(registration_method: registration_method) if registration_method
  }

  scope :by_train_template_type_id, lambda { |train_template_type_id|
    where(train_template_types: {id: train_template_type_id}) if train_template_type_id
  }

  scope :by_registration_date, lambda { |registration_date_begin, registration_date_end|
    if registration_date_begin && registration_date_end
      where(registration_date_begin: registration_date_begin...registration_date_end).or(
          where(registration_date_end: registration_date_begin...registration_date_end)
      )
    elsif registration_date_begin
      where('registration_date_end > :registration_date_begin', registration_date_begin: registration_date_begin)
    elsif registration_date_end
      where('registration_date_begin < :registration_date_end', registration_date_end: registration_date_end)
    end
  }

  scope :by_online_or_offline_training, lambda { |online_or_offline_training|
    where({online_or_offline_training: online_or_offline_training})  if online_or_offline_training
  }

  scope :by_training_credits, lambda { |training_credits|
    where({training_credits: training_credits}) if training_credits
  }


  def self.not_publish_count
    self.where(status: 'not_published').count
  end

  def self.has_been_published_count
    self.where(status: 'has_been_published').count
  end

  def self.signing_up_count
    self.where(status: 'signing_up').count
  end

  def self.registration_ends_count
    self.where(status: 'registration_ends').count
  end

  def self.training_count
    self.where(status: 'training').count
  end

  def self.completed_count
    self.where(status: 'completed').count
  end

  def self.cancelled_count
    self.where(status: 'cancelled').count
  end

  def self.train_template_type_options
    TrainTemplateType.where(id: self.pluck(:train_template_type_id))
  end

  def self.training_credits_options
    self.pluck(:training_credits).uniq.map do |item|
      value = item
      {
          key: value,
          chinese_name: value,
          english_name: value,
          simple_chinese_name: value
      }
    end
  end

  def self.create_options
    {
        positions: Position.all,
        departments: Department.all,
        locations: Location.all.where.not(id:32),
        grades: Config.get('selects').dig('grade', 'options'),
        division_of_jobs: Config.get('selects').dig('division_of_job', 'options')
    }
  end

  def self.field_options
    selects = Config.get('selects')
    statement_columns_base.map do |col|
      options_type = col['options_type']
      if options_type == 'options' && !col['options_action'].nil?
        [col['key'], {
            options: self.send(col['options_action'])
        }]
      elsif options_type == 'api'
        [col['key'], {
            options: col['options_endpoint']
        }]
      elsif options_type == 'predefined'
        [col['key'], {
            options: col['options_predefined']
        }]
      elsif options_type == 'selects'
        [col['key'], {
            options: selects.dig(col['options_select_key'], 'options')
        }]
      end
    end.compact.to_h.deep_symbolize_keys
  end


  def excute_publish
    targets = (self.can_join_train.pluck(:id) +  self.heads)&.compact&.uniq
    Message.add_notification(self, 'publish', targets) unless self.status == 'has_been_published'
    self.has_been_published
  end

  def has_been_published
    self.publish
    self.execute_signing_up
    self.execute_registration_ends
  end

  def signing_up
    self.update(status: :signing_up)
  end

  def registration_ends
    self.update(status: :registration_ends)
  end

  def training
    self.update(status: :training)
  end

  def completed
    ActiveRecord::Base.transaction do
      TrainRecordByTrain.create_after_train_complete(self)
      TrainRecord.create_train_records(self)
      self.final_lists&.each do |item|
        item.update!(attendance_percentage: TrainingService.calcul_attend_percentage(self, item.user),
                     test_score: TrainingService.calcul_test_score(self, item.user), working_status: item.working_status)
      end
      self.sign_lists&.each do |item|
        item.update(working_status: item.working_status)
        TrainingAbsentee.create_with_params(item.user, item)
      end
      self.entry_lists&.each do |item|
        item.update(working_status: item.working_status, is_can_be_absent: item.is_can_be_absent)
      end
      self.update(status: :completed, satisfaction_percentage: BigDecimal.new(self.calcul_satisfaction_percentage.to_s))
    end
  end

  def publish
    if self.registration_date_begin.beginning_of_day > Time.zone.now
      unless  self.status == 'has_been_published'
        self.update(status: :has_been_published)
      end
    end
  end

  def cancelled(reason)
    Message.add_notification(self, 'cancel', self.entry_lists&.pluck(:user_id), {reason: reason})
    self.update(status: :cancelled)
  end

  def self.execute_signing_up
    self.all.where(status: [1,3]).each do |item|
      item.execute_signing_up
    end
  end

  def execute_signing_up
    if (self.registration_date_begin.beginning_of_day) < Time.zone.now && (self.registration_date_end.end_of_day) > Time.zone.now
      unless self.status == 'signing_up'
        self.update(status: :signing_up)
      end
    end
  end

  def self.execute_registration_ends
    self.all.where(status: [1,2]).each do |item|
      item.execute_signing_up
    end
  end

  def execute_registration_ends
    if self.registration_date_end.end_of_day < Time.zone.now
      unless self.status == 'registration_ends'
        self.update(status: :registration_ends)
      end
    end
  end


  def  result_evaluation
    {
        attend_count: self.final_lists_count,
        evaluation_count: self.calcul_evaluation_count,
        satisfaction_percentage: self.calcul_satisfaction_percentage
    }
  end

  def calcul_evaluation_count
    StudentEvaluation.where(train_id: self.id, evaluation_status: :filled_in).count
  end

  def calcul_satisfaction_percentage
    if self.satisfaction_percentage
      self.satisfaction_percentage
    else
      StudentEvaluation.where(train_id: self.id, evaluation_status: :filled_in).average("satisfaction")
    end
  end

  def calcul_single_cost(user)
    TrainingService.calcul_single_cost(self, user)
  end

  def calcul_attend_percentage(user)
    TrainingService.calcul_attend_percentage(self, user)
  end

  def calcul_test_score(user)
    TrainingService.calcul_test_score(self, user)
  end

  def calcul_train_result(user)
    TrainingService.calcul_train_result(self, user)
  end

  def as_json(**arg)
    if arg[:methods].is_a?(Hash)
      json = super(arg.reject{|k,v| k == :methods})
      arg[:methods].each do |k,v|
        if self.respond_to?(k)
          if v
            json[k.to_s] = self.send(k,v)
          else
            json[k.to_s] = self.send(k)
          end
        end
      end
    else
      json = super(arg)
    end
    json
  end

  #es: StudentEvaluation
  def has_run_se
    StudentEvaluation.where(train_id: self.id).count > 0
  end
  #sa: SupervisorAssessment
  def has_run_sa
    SupervisorAssessment.where(train_id: self.id).count > 0
  end
  #tp: TrainingPaper
  def has_run_tp
    TrainingPaper.where(train_id: self.id).count > 0
  end
  #fl: FinalList
  def has_run_fl
    FinalList.where(train_id: self.id).count > 0
  end
end
