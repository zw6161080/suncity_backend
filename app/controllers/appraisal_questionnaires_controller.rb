class AppraisalQuestionnairesController < ApplicationController
  include StatementBaseActions
  include MineCheckHelper
  before_action :set_appraisal_questionnaire, only: [:show, :revise]
  before_action :set_appraisal, only: [:index, :options, :columns, :not_filled_in, :show, :show_by_assessor, :save, :batch_save, :submit, :batch_submit, :revise, :index_by_department, :index_by_mine]
  before_action :set_users, only: [:show, :show_by_assessor, :save, :batch_save, :submit, :batch_submit]
  before_action :myself?, only:[:show, :show_by_assessor, :save, :batch_save, :submit, :batch_submit], if: :entry_from_mine?
  def after_query(query = search_query)
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = query.order_by(sort_column , sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
            sort_column: sort_column.to_s,
            sort_direction: sort_direction.to_s,
        }
        render json: query, meta: meta, root: 'data', each_serializer: AppraisalQuestionnaireSerializer, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        appraisal_questionnaire_export_number_tag = Rails.cache.fetch('appraisal_questionnaire_export_number_tag', :expires_in => 24.hours) do
          1
        end
        Rails.cache.write('appraisal_questionnaire_export_number_tag', appraisal_questionnaire_export_number_tag + 1)
        export_id = ("0000"+ appraisal_questionnaire_export_number_tag.to_s).match(/\d{4}$/)[0]
        file_name = "#{@appraisal.date_begin.strftime('%Y/%m/%d')}~#{@appraisal.date_end.strftime('%Y/%m/%d')}_#{I18n.t(self.controller_name+'.file_name')}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns.concat(get_extra_columns).concat(ending_columns).map{|item| item.with_indifferent_access()},serializer: 'AppraisalQuestionnaireSerializer', options: JSON.parse(model.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def index
    query = @appraisal.appraisal_questionnaires
    query = search_query(query)
    after_query(query)
  end

  def index_by_department
    query = @appraisal.appraisal_questionnaires.joins(:assessor).where(:users => { department_id: current_user.department_id })
    query = search_query(query)
    after_query(query)
  end

  def index_by_mine
    query = @appraisal.appraisal_questionnaires.where(assessor_id: current_user.id)
    after_query(query)
  end

  def columns
    # authorize Appraisal
    render json: model.statement_columns.concat(get_extra_columns).concat(ending_columns)
  end

  def record_index
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query.order_by(sort_column , sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        #query = query.where(appraisal_id: Appraisal.where(appraisal_status: %w(completed performance_interview)).select(:id))
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
            sort_column: sort_column.to_s,
            sort_direction: sort_direction.to_s,
        }
        render json: query, meta: meta, root: 'data', each_serializer: AppraisalRecordQuestionnaireSerializer, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        appraisal_questionnaire_export_number_tag = Rails.cache.fetch('appraisal_questionnaire_export_number_tag', :expires_in => 24.hours) do
          1
        end
        Rails.cache.write('appraisal_questionnaire_export_number_tag', appraisal_questionnaire_export_number_tag + 1)
        export_id = ("0000"+ appraisal_questionnaire_export_number_tag.to_s).match(/\d{4}$/)[0]
        file_name = "#{I18n.t('appraisal_questionnaires_records'+'.file_name')}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns('appraisal_questionnaires_records'),serializer: 'AppraisalRecordQuestionnaireSerializer', options: JSON.parse(model.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def record_columns
    render json: model.statement_columns('appraisal_questionnaires_records')
  end

  def options
    # authorize Appraisal
    render json: AppraisalQuestionnaire.options('appraisal_questionnaires')
  end

  def record_options
    render json: AppraisalQuestionnaire.options('appraisal_questionnaires_records')
  end

  # GET /appraisals/:appraisal_id/appraisal_questionnaires/:id
  def show
    authorize Appraisal
    render json: @appraisal_questionnaire, include: '**'
  end

  # GET /appraisals/:appraisal_id/appraisal_questionnaires/show_by_assessor/:user_id
  def show_by_assessor
    render json: @appraisal.appraisal_questionnaires.where(assessor_id: params[:user_id]), include: '**'
  end

  # PATCH/PUT /appraisals/:appraisal_id/appraisal_questionnaires/:id
  def save
    authorize Appraisal
    AppraisalQuestionnaire.update_questionnaire(params)
    render json: { success: true }
  end


  def can_submit
    if can_questionnaire_submit(params[:questionnaire_id])
      render json: { can_submit: true }
      return
    end
    render json: { can_sumbit: false }
  end

  def submit
    authorize Appraisal
    if can_questionnaire_submit(params[:questionnaire_id])
      AppraisalQuestionnaire.change_questionnaire_status(params[:questionnaire_id])
      render json: { success: true }
      return
    end
    render json: { can_submit: false }
  end

  def batch_save
    params[:update_questionnaires].each do |update_params|
      AppraisalQuestionnaire.update_questionnaire(update_params)
    end
    render json: @appraisal.appraisal_questionnaires, include: '**'
  end

  def can_batch_submit
    params[:update_questionnaires].each do |update_params|
      if !can_questionnaire_submit(update_params[:questionnaire_id])
        render json: { can_sumbit: false }
        return
      end
    end
    render json: { can_submit: true }
  end

  def batch_submit
    params[:update_questionnaires].each do |update_params|
      if !can_questionnaire_submit(update_params[:questionnaire_id])
        render json: { can_sumbit: false }
        return
      end
    end
    params[:update_questionnaires].each do |update_params|
      # AppraisalQuestionnaire.update_questionnaire(update_params)
      AppraisalQuestionnaire.change_questionnaire_status(update_params[:questionnaire_id])
    end
    render json: @appraisal.appraisal_questionnaires, include: '**'
  end

  def revise
    authorize Appraisal
    # update
    AppraisalQuestionnaire.update_questionnaire(params[:update_questionnaire])
    # create revision history
    Questionnaire.find(params[:update_questionnaire][:questionnaire_id])
        .update(release_user_id: params[:revision][:user_id] || current_user.id,
                release_date: Time.zone.now)
    raise LogicError, { id: 422, message: "参数不存在" }.to_json unless params[:revision].permit(:user_id, :content, :revision_date)
    @appraisal_questionnaire.revision_histories.create(params[:revision].permit(:user_id, :content, :revision_date))
    render json: { success: true }
  end

  private
  def can_questionnaire_submit(questionnaire_id)
    AppraisalQuestionnaire.can_questionnaire_submit(questionnaire_id)
  end

  def set_users
    @users = User.where(id: @appraisal.assess_relationships.joins(:assessor).pluck("users.id").compact)
  end

  def set_appraisal
    # authorize Appraisal unless entry_from_mine? || (%w(options columns batch_save).include? params[:action])
    @appraisal = Appraisal.find(params[:appraisal_id])
  end

  def set_appraisal_questionnaire
    @appraisal_questionnaire = AppraisalQuestionnaire.find(params[:id])
  end

  def send_json(query, meta)
    render json: query, meta: meta, root: 'data', each_serializer: AppraisalQuestionnaireForTableSerializer, include: '**'
  end

  def filter(query)
    query.where(appraisal_id: params[:appraisal_id])
  end

  def ending_columns
    scope = [:statement_columns, :appraisal_questionnaires]
    [
      {
        key: 'release_user',
        chinese_name: I18n.t(:release_user, locale: 'zh-HK', scope: scope, default: ''),
        english_name: I18n.t(:release_user, locale: 'en', scope: scope, default: ''),
        simple_chinese_name: I18n.t(:release_user, locale: 'zh-CN', scope: scope, default: ''),
        data_index: 'questionnaire.release_user',
        search_type: 'search',
        value_type: 'obj_value',
        sorter: true
      },
      {
        key: 'release_date',
        chinese_name: I18n.t(:release_date, locale: 'zh-HK', scope: scope, default: ''),
        english_name: I18n.t(:release_date, locale: 'en', scope: scope, default: ''),
        simple_chinese_name: I18n.t(:release_date, locale: 'zh-CN', scope: scope, default: ''),
        data_index: 'questionnaire.release_date',
        search_type: 'date',
        value_type: 'date_value',
        value_format: 'yyyy/mm/dd',
        sorter: true
      }
    ]
  end

  def get_extra_columns
    columns = []
    # 获取所有涉及的问卷模板
    templates = @appraisal.appraisal_questionnaires.map do |appraisal_questionnaire|
      appraisal_questionnaire.questionnaire.questionnaire_template
    end
    # 去重
    templates = templates & templates
    templates.each do |template|
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
          data_index: "questionnaire.fill_in_the_blank_questions.#{column_index}.score_of_question"
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
          data_index: "questionnaire.choice_questions.#{column_index}.score_of_question"
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
          data_index: "questionnaire.matrix_single_choice_questions.#{column_index}.score_of_question"
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
            data_index: "questionnaire.matrix_single_choice_questions.#{column_index}.matrix_single_choice_items.#{column_index}.score"
          }
          columns << column
        end
      end
    end
    columns
  end

  def search_query(query = AppraisalQuestionnaire.all)
    query = query.joins({:assessor => :profile},{:appraisal_participator => {:user => :profile} }, :questionnaire ,:appraisal)
    %w(appraisal_date participator_empoid participator_name participator_location participator_department participator_position participator_grade assess_type submit_date release_user release_date questionnaire_status  assessor_empoid assessor_name assessor_department assessor_location assessor_position assessor_grade assessor_country departmental_appraisal_group).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end

end
