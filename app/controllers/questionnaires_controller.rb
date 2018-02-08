# coding: utf-8
class QuestionnairesController < ApplicationController
  include MineCheckHelper
  before_action :set_questionnaire, only: [:show, :destroy, :edit, :update]
  before_action :set_user, only: [:index]
  before_action :myself?, only:[:index], if: :entry_from_mine?

  def index
    authorize Questionnaire unless entry_from_mine?
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page
    final_result = format_result(result.as_json(include: [], methods: []))
    response_json final_result, meta: meta
  end

  def show
    # authorize Questionnaire unless entry_from_mine?
    response_json @questionnaire
  end

  def edit
    authorize Questionnaire unless entry_from_mine?
    questionnaire = Questionnaire.find(params[:id])
    unless questionnaire['is_filled_in']
      @questionnaire[:template] = QuestionnaireTemplate.detail_by_id @questionnaire['questionnaire_template_id']
    end
    response_json @questionnaire
  end

  def update
    authorize Questionnaire unless entry_from_mine?
    ActiveRecord::Base.transaction do
      questionnaire = Questionnaire.find(params[:id])
      questionnaire.update(questionnaire_params)

      questionnaire.fill_in_the_blank_questions.each { |q| q.destroy }
      questionnaire.choice_questions.each { |q| q.destroy }
      questionnaire.matrix_single_choice_questions.each { |q| q.destroy }

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
                                                             :answer))
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
                                                       :answer))

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
                                                 ))
          end
        end
      end

      questionnaire.save!

      judge_appointment(questionnaire)

      Message.add_notification(questionnaire, "fill_in_questionnaires", questionnaire['release_user_id'])

      response_json questionnaire.id
    end
  end

  def destroy
    authorize Questionnaire
    questionnaire = Questionnaire.find(params[:id])
    questionnaire.destroy
  end

  def options
    all_options = {}
    # filled_questionnaires = Questionnaire.where(is_filled_in: true)
    filled_questionnaires = Questionnaire.all

    template_ids = filled_questionnaires.pluck(:questionnaire_template_id)
    templates = QuestionnaireTemplate.where(id: template_ids)
    all_options[:filled_questionnaire_templates] = templates

    user_ids = filled_questionnaires.pluck(:user_id)
    users = User.where(id: user_ids)

    department_ids = users.pluck(:department_id)
    departments = Department.where(id: department_ids)

    position_ids = users.pluck(:position_id)
    positions = Position.where(id: position_ids)

    all_options[:filled_questionnaire_departments] = departments
    all_options[:filled_questionnaire_positions] = positions

    all_options[:status_options] = status_options

    response_json all_options
  end

  private

  def set_user
    @user = User.where(id: params[:user_id]).first
  end

  def set_questionnaire
    # @questionnaire = Questionnaire.detail_by_id params[:id]

    q = Questionnaire.find params[:id]

    @questionnaire = q.detail_json

    # @questionnaire = q.as_json(
    #   include: {
    #     user: {include: [:department, :location, :position ]},
    #     release_user: {},
    #     questionnaire_template: {},
    #     fill_in_the_blank_questions: {},
    #     choice_questions: {include: {options: {include: [:attend_attachments]}}},
    #     matrix_single_choice_questions: {include: [:matrix_single_choice_items]}
    #   }
    # )
  end

  def questionnaire_params
    params.require(:questionnaire).permit(
      :region,
      :questionnaire_template_id,
      :user_id,
      :is_filled_in,
      :release_date,
      :release_user_id,
      :submit_date,
      :comment
    )
  end

  def format_result(json)
    json.map do |hash|
      template = hash['questionnaire_template_id'] ? QuestionnaireTemplate.find_by(id: hash['questionnaire_template_id']) : nil
      hash['questionnaire_template'] = template ?
      {
        id: hash['questionnaire_template_id'],
        chinese_name: template['chinese_name'],
        english_name: template['english_name'],
        simple_chinese_name: template['chinese_name']
      } : nil

      user = hash['user_id'] ? User.find_by(id: hash['user_id']) : nil
      hash['user'] = user ?
      {
        id: hash['user_id'],
        chinese_name: user['chinese_name'],
        english_name: user['english_name'],
        simple_chinese_name: user['chinese_name'],
        empoid: user['empoid']
      } : nil

      department = user ? user.department : nil
      hash['department'] = department ?
      {
        id: department['id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['chinese_name']
      } : nil

      position = user ? user.position : nil
      hash['position'] = position ?
      {
        id: position['id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['chinese_name']
      } : nil

      release_user = hash['release_user_id'] ? User.find_by(id: hash['release_user_id']) : nil
      hash['release_user'] = release_user ?
      {
        id: hash['release_user_id'],
        chinese_name: release_user['chinese_name'],
        english_name: release_user['english_name'],
        simple_chinese_name: release_user['chinese_name']
      } : nil

      hash
    end
  end

  def search_query
    tag = false
    region = params[:region]
    locale = params[:locale] || 'zh-TW'

    lang = if locale == 'zh-TW'
             'chinese_name'
           elsif locale == 'zh-US'
             'english_name'
           else
             'simple_chinese_name'
           end

    questionnaires = Questionnaire
                       .by_user_id(params[:user_id])
                       .by_questionnaire_template_id(params[:questionnaire_template_id])
                       .by_user_name(params[:user_name], lang)
                       .by_empoid(params[:empoid])
                       .by_release_user_name(params[:release_user_name], lang)
                       .by_release_date(params[:release_start_date], params[:release_end_date])
                       .by_submit_date(params[:submit_start_date], params[:submit_end_date])
                       .by_filled_in(params[:is_filled_in])
                       .by_department_id(params[:department_id])
                       .by_position_id(params[:position_id])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
        questionnaires = questionnaires.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      else
        questionnaires = questionnaires.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end

      tag = true
    end

    questionnaires = questionnaires.order(:created_at) if tag == false

    questionnaires
  end

  def judge_appointment(questionnaire)
    EntryAppointment.where(questionnaire_id: questionnaire.id).each do |ea|
      if ea.status == 'wait_for_filling_in_the_questionnaire'
        ea.status = 'wait_for_making_the_appointment'
        ea.save!
      end
    end

    DimissionAppointment.where(questionnaire_id: questionnaire.id).each do |ea|
      if ea.status == 'wait_for_filling_in_the_questionnaire'
        ea.status = 'wait_for_making_the_appointment'
        ea.save!
      end
    end
  end

  def status_options
    [
      {
        key: true,
        chinese_name: '已填寫',
        english_name: 'Filled',
        simple_chinese_name: '已填写'
      },
      {
        key: false,
        chinese_name: '未填寫',
        english_name: 'Unfilled',
        simple_chinese_name: '未填写'
      }
    ]
  end
end
