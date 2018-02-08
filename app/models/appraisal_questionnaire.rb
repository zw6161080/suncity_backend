# == Schema Information
#
# Table name: appraisal_questionnaires
#
#  id                        :integer          not null, primary key
#  appraisal_id              :integer
#  appraisal_participator_id :integer
#  questionnaire_id          :integer
#  submit_date               :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  assess_type               :string
#  final_score               :decimal(5, 2)
#  assessor_id               :integer
#
# Indexes
#
#  index_appraisal_questionnaires_on_appraisal_id               (appraisal_id)
#  index_appraisal_questionnaires_on_appraisal_participator_id  (appraisal_participator_id)
#  index_appraisal_questionnaires_on_assessor_id                (assessor_id)
#  index_appraisal_questionnaires_on_questionnaire_id           (questionnaire_id)
#
# Foreign Keys
#
#  fk_rails_8f8e37871e  (appraisal_participator_id => appraisal_participators.id)
#  fk_rails_cde76d3269  (questionnaire_id => questionnaires.id)
#  fk_rails_dafce4896e  (assessor_id => users.id)
#  fk_rails_fea5542c4e  (appraisal_id => appraisals.id)
#

class AppraisalQuestionnaire < ApplicationRecord
  include StatementAble

  belongs_to :appraisal
  belongs_to :appraisal_participator
  belongs_to :assessor, :class_name => 'User', :foreign_key => 'assessor_id'

  belongs_to :questionnaire

  has_many :revision_histories, dependent: :destroy

  def count_questionnaire_score
    mqs = self.questionnaire.matrix_single_choice_questions
    total = mqs.count
    count = total if total > 0
    overall_score = mqs.collect(&:score_of_question).reduce(:+).to_f / (count || 1)
    self.update(final_score: overall_score.to_s)
  end

  def self.change_questionnaire_status(questionnaire_id)
    questionnaire = Questionnaire.find(questionnaire_id)
    raise LogicError, { id: 422, message: "问卷不存在" }.to_json unless questionnaire
    questionnaire.update(is_filled_in: true, submit_date: Time.zone.now)
  end
  def self.can_questionnaire_submit(questionnaire_id)
    questionnaire = Questionnaire.find(questionnaire_id)
    raise LogicError, { id: 422, message: "问卷不存在" }.to_json unless questionnaire
    questionnaire_template = questionnaire.questionnaire_template
    fill_in_questions = questionnaire_template.fill_in_the_blank_questions.count
    choice_questions = questionnaire_template.choice_questions.count
    matrix_single_choice_questions = questionnaire_template.matrix_single_choice_questions.count
    q_f_questions = questionnaire.fill_in_the_blank_questions.count
    q_c_questions = questionnaire.choice_questions.count
    q_m_s_c_questions = questionnaire.matrix_single_choice_questions.count
    # 不存在题目
    q_count = q_f_questions + q_c_questions + q_m_s_c_questions
    qt_count = fill_in_questions + choice_questions + matrix_single_choice_questions
    if q_count != qt_count
      return false
    end
    # 判断填空题目
    questionnaire.fill_in_the_blank_questions.each do |question|
      return false unless question.is_filled_in
    end
    # 判断选择题目
    questionnaire.choice_questions.each do |question|
      return false unless question.is_filled_in
    end
    # 判断矩阵题目
    questionnaire.matrix_single_choice_questions.each do |question|
      question.matrix_single_choice_items.each do |item|
        return false unless item.is_filled_in
      end
    end
    true
  end

  def self.update_questionnaire(params)
    ActiveRecord::Base.transaction do
      questionnaire = Questionnaire.find(params[:questionnaire_id])
      raise LogicError, { id: 422, message: "问卷不存在" }.to_json unless questionnaire
      questionnaire.fill_in_the_blank_questions.destroy_all
      questionnaire.choice_questions.destroy_all
      questionnaire.matrix_single_choice_questions.destroy_all

      if params[:fill_in_the_blank_questions]
        params[:fill_in_the_blank_questions].each do |question|
          questionnaire.fill_in_the_blank_questions.create(question.permit(
            :order_no,
            :question,
            :value,
            :score,
            :annotation,
            :right_answer,
            :is_required,
            :answer).merge(is_filled_in: !!question[:answer]))
        end
      end

      if params[:choice_questions]
        params[:choice_questions].each do |question|
          cq = questionnaire.choice_questions.create(question.permit(
            :order_no,
            :question,
            :value,
            :score,
            :annotation,
            :right_answer,
            :is_multiple,
            :is_required,
            :answer).merge(is_filled_in: !!question[:answer]))

          cq.answer = question['answer']
          cq.save

          options = question['options']
          options.each do |option|
            op = cq.options.create(option.permit(
              :option_no,
              :description,
              :supplement,
              :has_supplement
            ))
            attachment = option['attend_attachment']
            if attachment
              op.attend_attachments.create(attachment.permit(:file_name, :attachment_id))
            end
          end
        end
      end

      if params[:matrix_single_choice_questions]
        params[:matrix_single_choice_questions].each do |question|
          mq = questionnaire.matrix_single_choice_questions.create(question.permit(
            :order_no,
            :title,
            :value,
            :score,
            :annotation,
            :max_score))
          items = question['matrix_single_choice_items']
          items.each do |item|
            mq.matrix_single_choice_items.create(item.permit(
              :item_no,
              :question,
              :score,
              :right_answer,
              :is_required
            ).merge(is_filled_in: item[:score] == 0 ? false : !!item[:score] ))
          end
          ave_score = mq.matrix_single_choice_items.collect(&:score).compact.reduce(:+).to_f / mq.matrix_single_choice_items.count
          mq.update(score_of_question: ave_score)
        end
      end

      questionnaire.save!
    end
  end

  def self.copy_questions(questions)
    questions.map do |question|
      question_copy = question.dup
      question_copy.questionnaire_template_id = nil
      question_copy.save!
      question_copy
    end
  end

  def get_assess_type
    AssessRelationship.find_by(
      appraisal_id: self.appraisal_id,
      assessor_id: self.assessor_id,
      appraisal_participator_id: self.appraisal_participator_id
    ).assess_type
  end

  def self.joined_query(param_id = nil)
    self.left_outer_joins(
      [
        :assessor,
        {
          appraisal_participator: [:user]
        },
        :questionnaire
      ]
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
      Department.where(id: self.joins(:appraisal_participator => :user).select('users.department_id'))
    end

    def location_record_options
      Location.where(id: self.joins(:appraisal_participator  => :user).select('users.location_id'))
    end

    def position_record_options
      Position.where(id: self.joins(:appraisal_participator  => :user).select('users.position_id'))
    end

    def grade_record_options
      keys = self.joins(:appraisal_participator => :user).select('users.grade').map{|item| item['grade']}
      Config.get_option_from_selects('grade', keys)
    end
  end

  # assessors_appraisal_questionnaires
  scope :by_questionnaire_status, -> (is_filled_in) {
    where(:questionnaires => { is_filled_in: is_filled_in })
  }

  scope :by_submit_date, ->(submit_date) {
    from = Time.zone.parse(submit_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(submit_date[:end]).end_of_day rescue nil
    if from && to
      where('questionnaires.submit_date >= :from AND questionnaires.submit_date <= :to', from: from, to: to)
    elsif from
      where('questionnaires.submit_date >= :from', from: from)
    elsif to
      where('questionnaires.submit_date <= :to', to: to)
    end
  }
  # 评核者相关
  scope :by_assessor_empoid, -> (empoid) {
    where(:users => { empoid: empoid })
  }

  scope :by_assessor_name, -> (name) {
    where(:users => { chinese_name: name })
  }

  scope :by_assessor_department, -> (department) {
    where(:users => { department_id: department })
  }

  scope :by_assessor_location, -> (location) {
    where(:users => { location_id: location})
  }

  scope :by_assessor_position, -> (position) {
    where(:users => { position_id: position })
  }

  scope :by_assessor_grade, -> (grade) {
    where(:users => { grade: grade })
  }

  scope :by_assessor_country, -> (country) {
    includes({:assessor => :profile}).where("profiles.data #>> '{personal_information,field_values, certificate_issued_country}' = :country ", country: country)
  }



  # 被评核者相关
  scope :by_participator_empoid, -> (empoid) {
    where(:users_appraisal_participators => { empoid: empoid })
  }

  scope :by_participator_name, -> (name) {
    where(:users_appraisal_participators => { chinese_name: name })
  }

  scope :by_participator_department, -> (department) {
    where(:users_appraisal_participators => { department_id: department })
  }

  scope :by_participator_location, -> (location) {
    where(:users_appraisal_participators => { location_id: location })
  }

  scope :by_participator_position, -> (position) {
    where(:users_appraisal_participators => { position_id: position })
  }

  scope :by_participator_grade, -> (grade) {
    where(:users_appraisal_participators => { grade: grade })
  }

  scope :by_departmental_appraisal_group, -> (departmental_appraisal_group) {
    where(:appraisal_participators => { departmental_appraisal_group: departmental_appraisal_group } )
  }

  scope :by_assess_type, -> (assess_type) {
    where(assess_type: assess_type )
  }

  scope :by_release_user, -> (release_user) {
    where(:questionnaires => { release_user_id:  User.where('chinese_name = :name OR english_name = :name OR simple_chinese_name = :name', name: release_user).select(:id) })
  }

  scope :by_release_date, ->(release_date) {
    from = Time.zone.parse(release_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(release_date[:end]).end_of_day rescue nil
    if from && to
      where('release_date >= :from AND release_date <= :to', from: from, to: to)
    elsif from
      where('release_date >= :from', from: from)
    elsif to
      where('release_date <= :to', to: to)
    end
  }

  scope :by_appraisal_date, ->(appraisal_date) {
    from = Time.zone.parse(appraisal_date['begin']).beginning_of_day rescue nil
    to = Time.zone.parse(appraisal_date['end']).end_of_day rescue nil
    if from && to
      where('date_end >= :from AND date_begin <= :to', from: from, to: to)
    elsif from
      where('date_end >= :from', from: from)
    elsif to
      where('date_begin <= :to', to: to)
    end
  }

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :appraisal_date              then order("appraisals.date_begin #{sort_direction}")
      when :participator_empoid                then order("users_appraisal_participators.empoid #{sort_direction}")
      when :participator_name            then order("users_appraisal_participators.chinese_name #{sort_direction}")
      when :participator_location          then order("users_appraisal_participators.location_id #{sort_direction}")
      when :participator_department            then order("users_appraisal_participators.department_id #{sort_direction}")
      when :participator_position     then order("users_appraisal_participators.position_id #{sort_direction}")
      when :participator_grade     then order("users_appraisal_participators.grade #{sort_direction}")
      when :assess_type   then order("assess_type #{sort_direction}")
      when :submit_date              then order("submit_date #{sort_direction}")
      when :release_user                then order("questionnaires.release_user_id #{sort_direction}")
      when :release_date            then order("questionnaires.release_date #{sort_direction}")
      when :questionnaire_status          then order("questionnaires.is_filled_in #{sort_direction}")
      when :assessor_empoid            then order("users.empoid #{sort_direction}")
      when :assessor_name     then order("users.simple_chinese_name #{sort_direction}")
      when :assessor_department   then order("users.department_id #{sort_direction}")
      when :assessor_location                then order("users.location_id #{sort_direction}")
      when :assessor_position            then order("users.position_id #{sort_direction}")
      when :assessor_grade          then order("users.grade #{sort_direction}")
      when :assessor_country            then
            if sort_direction == :desc
              order("profiles.data #>> '{personal_information,field_values, certificate_issued_country}' DESC")
            else
              order("profiles.data #>> '{personal_information,field_values, certificate_issued_country}' ")
            end
      when :departmental_appraisal_group     then order("appraisal_participators.departmental_appraisal_group #{sort_direction}")

      else
        order(sort_column => sort_direction)
    end
  }

end
