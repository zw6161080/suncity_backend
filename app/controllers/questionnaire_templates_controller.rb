# coding: utf-8
class QuestionnaireTemplatesController < ApplicationController
  include StatementBaseActions

  before_action :set_questionnaire_template, only: [:show, :destroy, :update, :statistics, :export_xlsx]

  def index
    # authorize QuestionnaireTemplate
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
    # authorize QuestionnaireTemplate
    response_json @questionnaire_template
  end

  def create
    authorize QuestionnaireTemplate
    ActiveRecord::Base.transaction do
      questionnaire_template = QuestionnaireTemplate.create(questionnaire_template_params)

      if params[:fill_in_the_blank_questions]
        params[:fill_in_the_blank_questions].each do |question|
          questionnaire_template.fill_in_the_blank_questions.create(question.permit(
                                                                      :order_no,
                                                                      :question,
                                                                      :value,
                                                                      :score,
                                                                      :annotation,
                                                                      :right_answer,
                                                                      :is_required))
        end
      end

      if params[:choice_questions]
        params[:choice_questions].each do |question|
          cq = questionnaire_template.choice_questions.create(question.permit(
                                                                :order_no,
                                                                :question,
                                                                :value,
                                                                :score,
                                                                :annotation,
                                                                :right_answer,
                                                                :is_multiple,
                                                                :is_required))

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
          mq = questionnaire_template.matrix_single_choice_questions.create(question.permit(
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

      questionnaire_template.save!
      response_json questionnaire_template.id
    end
  end

  def update

    authorize QuestionnaireTemplate
    ActiveRecord::Base.transaction do
      questionnaire_template = QuestionnaireTemplate.find(params[:id])
      questionnaire_template.update(questionnaire_template_params)

      questionnaire_template.fill_in_the_blank_questions.each { |q| q.destroy }
      questionnaire_template.choice_questions.each { |q| q.destroy }
      questionnaire_template.matrix_single_choice_questions.each { |q| q.destroy }

      if params[:fill_in_the_blank_questions]
        params[:fill_in_the_blank_questions].each do |question|
          questionnaire_template.fill_in_the_blank_questions.create(question.permit(
                                                                      :order_no,
                                                                      :question,
                                                                      :value,
                                                                      :score,
                                                                      :annotation,
                                                                      :right_answer,
                                                                      :is_required))
        end
      end

      if params[:choice_questions]
        params[:choice_questions].each do |question|
          cq = questionnaire_template.choice_questions.create(question.permit(
                                                                :order_no,
                                                                :question,
                                                                :value,
                                                                :score,
                                                                :annotation,
                                                                :right_answer,
                                                                :is_multiple,
                                                                :is_required))

          cq.right_answer = question['right_answer']
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
          mq = questionnaire_template.matrix_single_choice_questions.create(question.permit(
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

      questionnaire_template.save!
      response_json questionnaire_template.id
    end
  end

  def destroy
    authorize QuestionnaireTemplate
    questionnaire_template = QuestionnaireTemplate.find(params[:id])
    questionnaire_template.destroy
  end

  def release
    authorize QuestionnaireTemplate
    ActiveRecord::Base.transaction do
      user_ids = if params[:user_ids]
                   params[:user_ids]
                 elsif params[:location_id] || params[:department_id] || params[:position_id]
                   users = User.where(location_id: params[:location_id]) if params[:location_id] > 0
                   users = User.where(department_id: params[:department_id]) if params[:department_id] > 0
                   users = User.where(position_id: params[:position_id]) if params[:position_id] > 0
                   users.pluck(:id)
                 else
                   []
                 end

      questionnaire_template = QuestionnaireTemplate.find(params[:questionnaire_template_id])

      user_ids.each do |user_id|
        template = params[:template]
        questionnaire = questionnaire_template.questionnaires.create(template.permit(
                                                                       :region,
                                                                       :questionnaire_template_id,
                                                                       :is_filled_in,
                                                                       :release_date,
                                                                       :release_user_id,
                                                                       :submit_date,
                                                                       :comment
                                                                     ))

        questionnaire.user_id = user_id
        questionnaire.save!
        Message.add_task(questionnaire, "release_questionnaires", user_id)
      end
    end
  end

  def instances
    params[:page] ||= 1
    meta = {}

    all_result = instances_search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    # final_result = format_result(result.as_json(include: [], methods: []))
    final_result = result.map { |instance| instance.detail_json }
    format_result = format_instance_result(final_result)

    response_json format_result, meta: meta
  end

  def export_xlsx

    all_result = instances_search_query
    over_time_export_num = Rails.cache.fetch('over_time_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('over_time_export_number_tag', over_time_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateStatementReportJob.perform_later(query_ids: all_result.ids, query_model: 'Questionnaire', statement_columns: model.statement_columns('questionnaire_templates', params[:id]).concat(get_extra_columns).map{|item| item.with_indifferent_access()}, options: JSON.parse(model.options('questionnaire_templates', params[:id]).to_json), my_attachment: my_attachment)
    render json: my_attachment
  end

  def statistics
    authorize QuestionnaireTemplate
    questionnaire_template = QuestionnaireTemplate.find(params[:id])
    all = questionnaire_template['questionnaires_count']
    is_filled_in = questionnaire_template.questionnaires.where(is_filled_in: true).count
    isnt_filled_in = all - is_filled_in
    result = {}
    result[:all] = all
    result[:is_filled_in] = is_filled_in
    result[:isnt_filled_in] = isnt_filled_in
    response_json result.as_json
  end

  def options
    all_options = {}
    all_options[:questionnaire_types] = questionnaire_types
    all_options[:questionnaire_templates] = QuestionnaireTemplate.where.not(template_type: 'train_template')
    response_json all_options
  end

  private

  def export_title
    if select_language.to_s == 'chinese_name'
      @qt.chinese_name
    elsif select_language.to_s == 'english_name'
      @qt.english_name
    else
      @qt.simple_chinese_name
    end

  end

  def set_questionnaire_template
    # @questionnaire_template = QuestionnaireTemplate.detail_by_id params[:id]

    @qt = QuestionnaireTemplate.find params[:id]

    @questionnaire_template = @qt.as_json(
      include: {
        fill_in_the_blank_questions: {},
        choice_questions: {include: {options: {include: [:attend_attachments]}}},
        matrix_single_choice_questions: {include: [:matrix_single_choice_items]}
      }
    )
  end

  def questionnaire_template_params
    params.require(:questionnaire_template).permit(
      :region,
      :chinese_name,
      :english_name,
      :simple_chinese_name,
      :template_type,
      :template_introduction,
      :creator_id,
      :comment
    )
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
      creator = hash['creator_id'] ? User.find(hash['creator_id']) : nil
      hash['creator'] = creator ?
      {
        id: hash['creator_id'],
        chinese_name: creator['chinese_name'],
        english_name: creator['english_name'],
        simple_chinese_name: creator['chinese_name']
      } : nil

      hash['questionnaire_type_name'] = find_questionnaire_type_name(hash['template_type'])

      hash['created_date'] = hash['created_at'].strftime("%Y/%m/%d")

      hash
    end
  end

  def format_instance_result(json)
    json.map do |hash|
      template = hash['questionnaire_template_id'] ? QuestionnaireTemplate.find(hash['questionnaire_template_id']) : nil
      hash['questionnaire_template'] = template ?
      {
        id: hash['questionnaire_template_id'],
        chinese_name: template['chinese_name'],
        english_name: template['english_name'],
        simple_chinese_name: template['chinese_name']
      } : nil


      user = hash['user_id'] ? User.find(hash['user_id']) : nil
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

      release_user = hash['release_user_id'] ? User.find(hash['release_user_id']) : nil
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

    questionnaire_templates = QuestionnaireTemplate
                                .where(region: region)
                                .where.not(template_type: 'train_template')
                                .by_creator_name(params[:creator_name], lang)
                                .by_created_date(params[:created_start_date], params[:created_end_date])
                                .by_template_type(params[:types])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'
      questionnaire_templates = questionnaire_templates.order("#{params[:sort_column]} #{params[:sort_direction]}")
      tag = true
    end

    questionnaire_templates = questionnaire_templates.order(:created_at) if tag == false

    questionnaire_templates
  end

  def instances_search_query
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

    questionnaire_template = QuestionnaireTemplate.find(params[:id])
    questionnaire_instances = questionnaire_template.questionnaires
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
        questionnaire_instances = questionnaire_instances.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      else
        questionnaire_instances = questionnaire_instances.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    questionnaire_instances = questionnaire_instances.order(:created_at) if tag == false

    questionnaire_instances
  end

  def find_questionnaire_type_name(type)
    type_options = questionnaire_types
    type_options.select { |op| op[:key] == type }.first
  end

  def questionnaire_types
    [
      {
        key: 'entry_questionnaire',
        chinese_name: '入職面談調查問卷',
        english_name: 'Entry interview questionnaire',
        simple_chinese_name: '入职面谈调查问卷'
      },
      {
        key: 'leave_questionnaire',
        chinese_name: '離職面談調查問卷',
        english_name: 'Exit interview questionnaire',
        simple_chinese_name: '离职面谈调查问卷'
      },
      {
        key: '360_assessment',
        chinese_name: '360 評核問卷',
        english_name: '360 assessment questionnaire',
        simple_chinese_name: '360 评核问卷'
      },
      {
        key: 'train_exam',
        chinese_name: '培訓考試',
        english_name: 'Training test',
        simple_chinese_name: '培训考试'
      },
      {
        key: 'train_student_evaluation',
        chinese_name: '培訓學員評價',
        english_name: 'Train student evaluation',
        simple_chinese_name: '培训学员评价'
      },
      {
        key: 'train_supervisor_assessment',
        chinese_name: '培訓上司考核',
        english_name: 'Train supervisor assessment',
        simple_chinese_name: '培训上司考核'
      },
      {
        key: 'client_feedback',
        chinese_name: '客戶意見問卷',
        english_name: 'Customer opinion questionnaire',
        simple_chinese_name: '客户意见问卷'
      },
      {
        key: 'other',
        chinese_name: '其他',
        english_name: 'Others',
        simple_chinese_name: '其他'
      },
    ]
  end

  def get_extra_columns

    columns = []
    template = @qt
      column_index = 0
      template.fill_in_the_blank_questions.each do |fill_question|
        column = {
            key: "template_id_#{template.id}_fill_in_the_blank_question_order_no_#{fill_question.order_no}",
            chinese_name: fill_question.question,
            english_name: fill_question.question,
            simple_chinese_name: fill_question.question,
            template_id: template.id,
            question_order_no: fill_question.order_no,
            question_type: 'fill_in_the_blank_questions',
            data_index: "fill_in_the_blank_questions.#{column_index}.score"
        }
        columns << column
        column_index += 1
      end

      template.choice_questions.each do |choice_question|
        column = {
            key: "template_id_#{template.id}_choice_questions_order_no_#{choice_question.order_no}",
            chinese_name: choice_question.question,
            english_name: choice_question.question,
            simple_chinese_name: choice_question.question,
            template_id: template.id,
            question_order_no: choice_question.order_no,
            question_type: 'choice_questions',
            data_index: "choice_questions.#{column_index}.score"
        }
        columns << column
        column_index += 1
      end

      template.matrix_single_choice_questions.each do |matrix_question|
        column = {
            key: "template_id_#{template.id}_matrix_single_choice_questions_order_no_#{matrix_question.order_no}",
            chinese_name: matrix_question.title,
            english_name: matrix_question.title,
            simple_chinese_name: matrix_question.title,
            template_id: template.id,
            question_order_no: matrix_question.order_no,
            question_type: 'matrix_single_choice_questions',
            data_index: "matrix_single_choice_questions.#{column_index}.score"
        }
        columns << column
        column_index += 1

        matrix_question.matrix_single_choice_items.each do |matrix_question_item|
          column = {
              key: "template_id_#{template.id}_matrix_single_choice_questions_order_no_#{matrix_question.order_no}_item_no_#{matrix_question_item.item_no}",
              chinese_name: matrix_question_item.question,
              english_name: matrix_question_item.question,
              simple_chinese_name: matrix_question_item.question,
              template_id: template.id,
              question_order_no: matrix_question.order_no,
              item_order_no: matrix_question_item.item_no,
              question_type: 'matrix_single_choice_questions_matrix_single_choice_items',
              data_index: "matrix_single_choice_questions.#{column_index}.matrix_single_choice_items.#{column_index}.score"
          }
          columns << column
        end
      end
    columns
  end
end
