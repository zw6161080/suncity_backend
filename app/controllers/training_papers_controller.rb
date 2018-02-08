# coding: utf-8
class TrainingPapersController < ApplicationController
  include GenerateXlsxHelper
  include CurrentUserHelper
  def index
    authorize TrainingPaper
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: {
                                                  attend_attachments: {},
                                                }, methods: []))

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
    tp = TrainingPaper.find(params[:id])
    training_paper = tp.as_json(
      include: {
        user: {include: [:department, :location, :position ], methods: :career_entry_date},
        questionnaire: {},
        questionnaire_template: {}
      }
    )
    response_json training_paper
  end


  def update
    ActiveRecord::Base.transaction do
      tp = TrainingPaper.find(params[:id])
      tp.update(training_paper_params)

      current_user_id = params[:creator_id]

      if params[:score]
        sa = SupervisorAssessment.where(train_id: tp.train_id, user_id: tp.user_id).first
        if sa
          sa.score = params[:score]
          sa.save
        end
      end

      if params[:attend_attachments]
        params[:attend_attachments].each do |attend_attachment|
          tp.attend_attachments.create(attend_attachment.permit(:file_name, :comment, :attachment_id).merge({creator_id: current_user_id}))
        end
      end

      response_json tp.id
    end
  end

  def update_questionnaire
    ActiveRecord::Base.transaction do
      tp = TrainingPaper.find(params[:id])
      questionnaire = tp.questionnaire ? tp.questionnaire : Questionnaire.new

      questionnaire.user_id = tp.user_id
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

      tp.questionnaire = questionnaire
      tp.paper_status = 0
      tp.filled_in_date = DateTime.current
      tp.save!

      response_json tp.id
    end
  end

  def upload_file
    training_paper = TrainingPaper.find_by(id: params[id])
    if params[:attachments]
      params[:attachments].each do |attachment|
        training_paper.attend_attachments.create(attachment.permit(:file_name, :comment, :attachment_id, :creator_id))
      end
      training_paper.latest_upload_date = Time.zone.now.to_date
      training_paper.save
    end
  end

  def export_xlsx
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    train = Train.find(params[:train_id])

    begin_date = train['train_date_begin'].strftime('%Y/%m/%d')
    end_date = train['train_date_end'].strftime('%Y/%m/%d')

    exam_mode_type = params[:exam_mode]

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{train['chinese_name']}培訓(#{train['train_number']})_#{begin_date}~#{end_date}_培訓試卷_#{Time.zone.now.strftime('%Y%m%d')}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'TrainingPapersController', table_fields_methods: 'get_training_papers_table_fields', table_fields_args: [exam_mode_type], my_attachment: my_attachment, sheet_name: 'TrainingPapersTable')
    render json: my_attachment
  end

  def options
    all_options = {}
    all_options[:employment_status_types] = employment_status_types
    all_options[:exam_mode_types] = exam_mode_types
    all_options[:paper_status_types] = paper_status_types

    training_papers = TrainingPaper.where(train_id: params[:train_id])

    user_ids = training_papers.pluck(:user_id)
    users = User.where(id: user_ids)

    department_ids = users.pluck(:department_id)
    departments = Department.where(id: department_ids)

    position_ids = users.pluck(:position_id)
    positions = Position.where(id: position_ids)

    all_options[:departments] = departments
    all_options[:positions] = positions

    all_options[:filled_in_date] = training_papers.pluck(:filled_in_date).compact
    all_options[:latest_upload_date] = training_papers.pluck(:latest_upload_date).compact

    response_json all_options
  end

  private

  def training_paper_params
    params.require(:training_paper).permit(
      :region,
      :user_id,
      :employment_status,
      :exam_mode,
      :paper_status,
      :attendance_rate,
      :score,
      :correct_percentage,
      :filled_in_date,
      :latest_upload_date,
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

    training_papers = TrainingPaper.where(region: region)
                        .by_train(params[:train_id])
                        .by_user_name(params[:user_name], lang)
                        .by_empoid(params[:empoid])
                        .by_department(params[:department_id])
                        .by_position(params[:position_id])
                        .by_employment_status(params[:employment_status])
                        .by_exam_mode(params[:exam_mode])
                        .by_paper_status(params[:paper_status])
                        .by_score(params[:score])
                        .by_attendance_rate(params[:attendance_rate])
                        .by_correct_percentage(params[:correct_percentage])
                        .by_filled_in_date(params[:filled_in_date])
                        .by_latest_upload_date(params[:latest_upload_date])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
        training_papers = training_papers.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      else
        training_papers = training_papers.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    training_papers = training_papers.order(:created_at) if tag == false

    training_papers
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
      hash['paper_status_name'] = find_paper_status_name(hash['paper_status'])

      hash
    end
  end

  def find_employment_status_name(status)
    status_options = employment_status_types
    status_options.select { |op| op[:key] == status }.first
  end

  def find_exam_mode_name(mode)
    mode_options = exam_mode_types
    mode_options.select { |op| op[:key] == mode }.first
  end

  def find_paper_status_name(status)
    status_options = paper_status_types
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

  def paper_status_types
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

  def self.get_training_papers_table_fields(exam_mode_type)
    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["employee"][options[:name_key]]
      }
    }

    employee_id = {
      chinese_name: '員工編號',
      english_name: 'ID',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        user = User.find(rst["user_id"])
        user["empoid"].rjust(8, '0')
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

    paper_status = {
      chinese_name: '試卷狀態',
      english_name: 'Test paper status',
      simple_chinese_name: '试卷状态',
      get_value: -> (rst, options){
        rst['paper_status_name'] ? rst['paper_status_name'][options[:name_key]] : ''
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

    correct_percentage = {
      chinese_name: '試卷正確百分比',
      english_name: 'The correct percentage of the papers',
      simple_chinese_name: '试卷正确百分比',
      get_value: -> (rst, options){
        rst['correct_percentage'] ? "#{rst['correct_percentage']}%" : ''
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

    upload_files = {
      chinese_name: '相關文件',
      english_name: 'Upload Files',
      simple_chinese_name: '相关文件',
      get_value: -> (rst, options){
        rst['attend_attachments'] ? rst['attend_attachments'].map { |atc| atc['file_name'] }.join(', ') : ''
      }
    }

    latest_upload_date = {
      chinese_name: '最新上傳日期',
      english_name: 'Latest upload date',
      simple_chinese_name: '最新上传日期',
      get_value: -> (rst, options){
        rst['latest_upload_date'] ? Time.zone.parse(rst['latest_upload_date']).strftime('%Y/%m/%d') : ''
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

    basic_fields = [ name, employee_id, department, position, employment_status,
                     exam_mode, score, attendance_rate ]

    paper_fields = [paper_status, correct_percentage, filled_in_date]

    other_fields = [upload_files, latest_upload_date, comment]

    table_fields = exam_mode_type == 'offline' ? (basic_fields + other_fields) : (basic_fields + paper_fields + other_fields)

  end
end
