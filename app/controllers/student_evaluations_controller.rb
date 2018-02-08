# coding: utf-8
class StudentEvaluationsController < ApplicationController
  include GenerateXlsxHelper
  include CurrentUserHelper
  def index
    authorize StudentEvaluation
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

  def index_by_mine
    params[:page] ||= 1
    meta = {}

    all_result = search_query
    results = all_result.where(user_id: current_user.id)
    meta['total_count'] = results.count
    result = results.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def index_by_department
    params[:page] ||= 1
    meta = {}

    all_result = search_query
    results = all_result.includes(:user).where(:users => {department_id: current_user.department_id})
    meta['total_count'] = results.count
    result = results.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def show
    se = StudentEvaluation.find(params[:id])
    student_evaluation = se.as_json(
      include: {
        user: {include: [:department, :location, :position ], methods: :career_entry_date},
        lecturer: {include: [:department, :location, :position ]},
        questionnaire: {},
        questionnaire_template: {}
      }
    )
    response_json student_evaluation
  end

  def update
    se = StudentEvaluation.find(params[:id])
    se.update(student_evaluation_params)
    response_json se.id
  end

  def update_questionnaire
    ActiveRecord::Base.transaction do
      se = StudentEvaluation.find(params[:id])
      questionnaire = se.questionnaire ? se.questionnaire : Questionnaire.new

      questionnaire.user_id = se.user_id
      questionnaire.is_filled_in = true
      questionnaire.questionnaire_template_id = params[:questionnaire_template_id]
      questionnaire.submit_date = DateTime.current
      questionnaire.save

      # TODO
      # questionnaire.update(questionnaire_params)

      questionnaire.fill_in_the_blank_questions.each { |q| q.destroy }
      questionnaire.choice_questions.each { |q| q.destroy }
      questionnaire.matrix_single_choice_questions.each { |q| q.destroy }

      if params[:fill_in_the_blank_questions]
        params[:fill_in_the_blank_questions].each do |question|
          questionnaire.fill_in_the_blank_questions.create(question.permit(
                                                             :order_no,
                                                             :question,
                                                             :is_required,
                                                             :answer))
        end
      end

      if params[:choice_questions]
        params[:choice_questions].each do |question|
          cq = questionnaire.choice_questions.create(question.permit(
                                                       :order_no,
                                                       :question,
                                                       :is_multiple,
                                                       :is_required,
                                                       :answer))
          cq.answer = question['answer']
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
              op.attend_attachments.create(attachment.permit(:attachment_id))
            end
          end
        end
      end

      if params[:matrix_single_choice_questions]
        real_score, total_score = 0, 0

        params[:matrix_single_choice_questions].each do |question|
          mq = questionnaire.matrix_single_choice_questions.create(question.permit(
                                                                     :order_no,
                                                                     :title,
                                                                     :max_score))
          items = question['matrix_single_choice_items']
          items.each do |item|
            mq.matrix_single_choice_items.create(item.permit(
                                                   :item_no,
                                                   :question,
                                                   :score,
                                                   :is_required
                                                 ))
          end

          tmp_real_score = items.reduce(0) { |total, item| total += item[:score] }
          max_score = question[:max_score]
          real_score = real_score + tmp_real_score
          total_score = total_score + max_score * items.count
        end

        if params[:matrix_single_choice_questions].count != 0
          if total_score == 0
            satisfaction = 1
          else
            satisfaction = (BigDecimal(real_score.to_s) / BigDecimal(total_score.to_s)).round(2)
          end
          se.satisfaction = satisfaction
        else
          se.satisfaction = 1
        end
      else
        se.satisfaction = 1
      end

      questionnaire.save!

      se.questionnaire = questionnaire
      se.evaluation_status = 0
      se.filled_in_date = DateTime.current
      se.save!

      response_json se.id
    end
  end

  def export_xlsx
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    train = Train.find(params[:train_id])

    begin_date = train['train_date_begin'].strftime('%Y/%m/%d')
    end_date = train['train_date_end'].strftime('%Y/%m/%d')

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{train['chinese_name']}培訓(#{train['train_number']})_#{begin_date}~#{end_date}_學員評價_#{Time.zone.now.strftime('%Y%m%d')}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'StudentEvaluationsController', table_fields_methods: 'get_student_evaluations_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'StudentEvaluationsTable')
    render json: my_attachment
  end

  def options
    all_options = {}
    all_options[:employment_status_types] = employment_status_types
    all_options[:evaluation_status_types] = evaluation_status_types

    student_evaluations = StudentEvaluation.where(train_id: params[:train_id])

    user_ids = student_evaluations.pluck(:user_id)
    users = User.where(id: user_ids)

    department_ids = users.pluck(:department_id)
    departments = Department.where(id: department_ids)

    position_ids = users.pluck(:position_id)
    positions = Position.where(id: position_ids)

    all_options[:departments] = departments
    all_options[:positions] = positions

    all_options[:filled_in_date] = student_evaluations.pluck(:filled_in_date).compact
    response_json all_options
  end

  private

  def student_evaluation_params
    params.require(:student_evaluation).permit(
      :region,
      :user_id,
      :employment_status,
      :training_type,
      :evaluation_status,
      :satisfaction,
      :filled_in_date,
      :lecturer_id,
      :comment,
      :questionnaire_template_id,
      :questionnaire_id,
    )
  end

  def search_query
    tag = false
    region = params[:region] || 'macau'
    lang_key = params[:lang] || 'zh-TW'

    lang = if lang_key == 'zh-TW'
             'chinese_name'
           elsif lang_key == 'zh-US'
             'english_name'
           else
             'simple_chinese_name'
           end


    student_evaluations = StudentEvaluation.where(region: region)
                            .by_train(params[:train_id])
                            .by_user_name(params[:user_name])
                            .by_name(params[:user_name])
                            .by_empoid(params[:empoid])
                            .by_trainer(params[:trainer])
                            .by_department(params[:department_id])
                            .by_position(params[:position_id])
                            .by_employment_status(params[:employment_status])
                            .by_lecturer(params[:lecturer], lang)
                            .by_satisfaction(params[:satisfaction])
                            .by_evaluation_status(params[:evaluation_status])
                            .by_filled_in_date(params[:filled_in_date])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
        student_evaluations = student_evaluations.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      else
        student_evaluations = student_evaluations.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    student_evaluations = student_evaluations.order(:created_at) if tag == false

    student_evaluations
  end

  def format_result(json)
    json.map do |hash|
      employee = hash['user_id'] ? User.find(hash['user_id']) : nil
      hash['employee'] = employee ?
      {
        id: hash['user_id'],
        chinese_name: employee['chinese_name'],
        english_name: employee['english_name'],
        simple_chinese_name: employee['chinese_name'],
        empoid: employee['empoid']
      } : nil


      department = employee ? employee.department : nil
      hash['department'] = department ?
      {
        id: department['id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['chinese_name']
      } : nil

      position = employee ? employee.position : nil
      hash['position'] = position ?
      {
        id: position['id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['chinese_name']
      } : nil


      hash['employment_status_name'] = find_employment_status_name(hash['employment_status'])
      hash['evaluation_status_name'] = find_evaluation_status_name(hash['evaluation_status'])

      lecturer = hash['lecturer_id'] ? User.find(hash['lecturer_id']) : nil
      hash['lecturer'] = lecturer ?
      {
        id: hash['lecturer_id'],
        chinese_name: lecturer['chinese_name'],
        english_name: lecturer['english_name'],
        simple_chinese_name: lecturer['chinese_name'],
      } : nil

      hash
    end
  end

  def find_employment_status_name(status)
    status_options = employment_status_types
    status_options.select { |op| op[:key] == status }.first
  end

  def find_evaluation_status_name(status)
    status_options = evaluation_status_types
    status_options.select { |op| op[:key] == status }.first
  end

  def employment_status_types
    [
      {
        key: 'in_service',
        chinese_name: '在職',
        english_name: 'In service',
        simple_chinese_name: '在职'
      },
      {
        key: 'dimission',
        chinese_name: '離職',
        english_name: 'Turnover',
        simple_chinese_name: '离职'
      }
    ]
  end

  def evaluation_status_types
    [
      {
        key: 'filled_in',
        chinese_name: '已填寫',
        english_name: 'Filled',
        simple_chinese_name: '已填写'
      },
      {
        key: 'unfilled',
        chinese_name: '未填寫',
        english_name: 'Unfilled',
        simple_chinese_name: '未填写'
      }
    ]
  end

  def self.get_student_evaluations_table_fields
    employee_id = {
      chinese_name: '員工編號',
      english_name: 'ID',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        user = User.find(rst["user_id"])
        user["empoid"].rjust(8, '0')
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["employee"][options[:name_key]]
      }
    }

    department = {
      chinese_name: '部門',
      english_name: 'Department',
      simple_chinese_name: '部门',
      get_value: -> (rst, options){
        rst['department'] ? rst['department'][options[:name_key]] : ''
      }
    }

    position = {
      chinese_name: '職位',
      english_name: 'Position',
      simple_chinese_name: '职位',
      get_value: -> (rst, options){
        rst['position'] ? rst['position'][options[:name_key]] : ''
      }
    }

    employment_status = {
      chinese_name: '培訓期間狀態',
      english_name: 'State during the training',
      simple_chinese_name: '培训期间状态',
      get_value: -> (rst, options){
        rst['employment_status_name'] ? rst['employment_status_name'][options[:name_key]] : ''
      }
    }

    lecturer = {
      chinese_name: '授課導師/機構/單位',
      english_name: 'Instructor / Institution / Unit',
      simple_chinese_name: '授课导师/机构/单位',
      get_value: -> (rst, options){
        rst["lecturer"] ? rst["lecturer"][options[:name_key]] : ''
      }
    }

    satisfaction = {
      chinese_name: '課程滿意度',
      english_name: 'Satisfaction',
      simple_chinese_name: '课程满意度',
      get_value: -> (rst, options){
        rst['satisfaction'] ? "#{rst['satisfaction']}%" : ''
      }
    }

    evaluation_status = {
      chinese_name: '員工評價狀態',
      english_name: 'Staff evaluation status',
      simple_chinese_name: '员工评价状态',
      get_value: -> (rst, options){
        rst['evaluation_status_name'] ? rst['evaluation_status_name'][options[:name_key]] : ''
      }
    }

    filled_in_date = {
      chinese_name: '填寫日期',
      english_name: 'Filling date',
      simple_chinese_name: '填写日期',
      get_value: -> (rst, options){
        rst['filled_in_date'] ? Time.zone.parse(rst['filled_in_date']).strftime('%Y/%m/%d') : ''
      }
    }

    comment = {
      chinese_name: '備註',
      english_name: 'Remarks',
      simple_chinese_name: '备注',
      get_value: -> (rst, options){
        rst['comment'] ? rst["comment"] : ''
      }
    }

    table_fields = [ name, employee_id, department, position, employment_status,
                     lecturer, satisfaction, evaluation_status,
                     filled_in_date, comment ]


  end
end
