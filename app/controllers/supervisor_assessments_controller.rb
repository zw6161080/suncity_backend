# coding: utf-8
class SupervisorAssessmentsController < ApplicationController
  include GenerateXlsxHelper
  include CurrentUserHelper
  def index
    authorize SupervisorAssessment
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
    sa = SupervisorAssessment.find(params[:id])
    supervisor_assessment = sa.as_json(
      include: {
        user: {include: [:department, :location, :position ], methods: :career_entry_date},
        questionnaire: {},
        questionnaire_template: {}
        # lecture: {include: [:department, :location, :position ]},
      }
    )
    response_json supervisor_assessment
  end

  def update
    sa = SupervisorAssessment.find(params[:id])
    sa.update(supervisor_assessment_params)
    response_json sa.id
  end

  def update_questionnaire
    ActiveRecord::Base.transaction do
      sa = SupervisorAssessment.find(params[:id])
      questionnaire = sa.questionnaire ? sa.questionnaire : Questionnaire.new

      questionnaire.user_id = sa.user_id
      questionnaire.is_filled_in = true
      questionnaire.questionnaire_template_id = params[:questionnaire_template_id]
      questionnaire.submit_date = DateTime.current
      questionnaire.save

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
        end
      end

      questionnaire.save!

      sa.questionnaire = questionnaire
      sa.assessment_status = 0
      sa.filled_in_date = DateTime.current
      sa.save!

      response_json sa.id
    end
  end

  def export_xlsx
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))

    lang_key = params[:lang] || 'zh-TW'
    name_key = if lang_key == 'zh-CN'
                 :simple_chinese_name
               elsif lang_key == 'zh-US'
                 :english_name
               else
                 :chinese_name
               end

    train = Train.find(params[:train_id])

    begin_date = train['train_date_begin'].strftime('%Y/%m/%d')
    end_date = train['train_date_end'].strftime('%Y/%m/%d')

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{train['chinese_name']}培訓(#{train['train_number']})_#{begin_date}~#{end_date}_上司考核_#{Time.zone.now.strftime('%Y%m%d')}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'SupervisorAssessmentsController', table_fields_methods: 'get_supervisor_assessment_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'SupervisorAssessmentsTable')
    render json: my_attachment
  end

  def options
    all_options = {}
    all_options[:employment_status_types] = employment_status_types
    all_options[:training_result_types] = training_result_types
    all_options[:exam_mode_types] = exam_mode_types
    all_options[:assessment_status_types] = assessment_status_types

    supervisor_assessments = SupervisorAssessment.where(train_id: params[:train_id])

    user_ids = supervisor_assessments.pluck(:user_id)
    users = User.where(id: user_ids)

    department_ids = users.pluck(:department_id)
    departments = Department.where(id: department_ids)

    position_ids = users.pluck(:position_id)
    positions = Position.where(id: position_ids)

    all_options[:departments] = departments
    all_options[:positions] = positions

    all_options[:filled_in_date] = supervisor_assessments.pluck(:filled_in_date).compact
    response_json all_options
  end

  private

  def supervisor_assessment_params
    params.require(:supervisor_assessment).permit(
      :region,
      :user_id,
      :employment_status,
      :exam_mode,
      :training_result,
      :score,
      :attendance_rate,
      :assessment_status,
      :filled_in_date,
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


    supervisor_assessments = SupervisorAssessment.where(region: region)
                               .by_train(params[:train_id])
                               .by_user_name(params[:user_name], lang)
                               .by_empoid(params[:empoid])
                               .by_department(params[:department_id])
                               .by_position(params[:position_id])
                               .by_employment_status(params[:employment_status])
                               .by_training_result(params[:training_result])
                               .by_exam_mode(params[:exam_mode])
                               .by_attendance_rate(params[:attendance_rate])
                               .by_score(params[:score])
                               .by_assessment_status(params[:assessment_status])
                               .by_filled_in_date(params[:filled_in_date])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
        supervisor_assessments = supervisor_assessments.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      else
        supervisor_assessments = supervisor_assessments.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    supervisor_assessments = supervisor_assessments.order(:created_at) if tag == false

    supervisor_assessments
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
      hash['exam_mode_name'] = find_exam_mode_name(hash['exam_mode'])
      hash['training_result_name'] = find_training_result_name(hash['training_result'])
      hash['assessment_status_name'] = find_assessment_status_name(hash['assessment_status'])

      hash
    end
  end

  def find_employment_status_name(status)
    status_options = employment_status_types
    status_options.select { |op| op[:key] == status }.first
  end

  def find_training_result_name(result)
    mode_options = training_result_types
    mode_options.select { |op| op[:key] == result }.first
  end

  def find_exam_mode_name(mode)
    mode_options = exam_mode_types
    mode_options.select { |op| op[:key] == mode }.first
  end

  def find_assessment_status_name(status)
    status_options = assessment_status_types
    status_options.select { |op| op[:key] == status }.first
  end

  def employment_status_types
    [
      {
        key: 'in_service',
        chinese_name: '在職',
        english_name: 'In Service',
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

  def training_result_types
    [
      {
        key: 'pass',
        chinese_name: '通過',
        english_name: 'Pass',
        simple_chinese_name: '通过'
      },
      {
        key: 'fail',
        chinese_name: '未通過',
        english_name: 'Failed',
        simple_chinese_name: '通過'
      }
    ]
  end

  def exam_mode_types
    [
      {
        key: 'online',
        chinese_name: '線上考試',
        english_name: 'Online test',
        simple_chinese_name: '线上考试'
      },
      {
        key: 'offline',
        chinese_name: '線下考試',
        english_name: 'Offline test',
        simple_chinese_name: '线下考试'
      }
    ]
  end

  def assessment_status_types
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

  def self.get_supervisor_assessment_table_fields
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

    exam_mode = {
      chinese_name: '考試形式',
      english_name: 'Test format',
      simple_chinese_name: '考试形式',
      get_value: -> (rst, options){
        rst['exam_mode_name'] ? rst['exam_mode_name'][options[:name_key]] : ''
      }
    }

    training_result = {
      chinese_name: '培訓結果',
      english_name: 'Training result',
      simple_chinese_name: '培训结果',
      get_value: -> (rst, options){
        rst['training_result_name'] ? rst['training_result_name'][options[:name_key]] : ''
      }
    }

    assessment_status = {
      chinese_name: '上司評核狀態',
      english_name: 'Supervisor status',
      simple_chinese_name: '上司评核状态',
      get_value: -> (rst, options){
        rst['assessment_status_name'] ? rst['assessment_status_name'][options[:name_key]] : ''
      }
    }

    score = {
      chinese_name: '分數',
      english_name: 'Score',
      simple_chinese_name: '分数',
      get_value: -> (rst, options){
        rst['score'] ? rst['score'] : ''
      }
    }

    attendance_rate = {
      chinese_name: '出席率',
      english_name: 'Attendance rate',
      simple_chinese_name: '出席率',
      get_value: -> (rst, options){
        rst['attendance_rate'] ? "#{rst['attendance_rate']}%" : ''
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
                     exam_mode, training_result, attendance_rate, score,
                     assessment_status, filled_in_date, comment ]

  end
end
