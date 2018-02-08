# coding: utf-8
class TrainsController < ApplicationController
  include StatementBaseActions
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  include SortParamsHelper
  include TrainHelper
  include MineCheckHelper
  before_action :set_train, only: [
      :introduction,:introduction_by_current_user, :train_classes, :train_classes_by_current_user, :train_classes_by_current_user, :classes, :titles, :online_materials, :online_materials_by_current_user,
      :update, :entry_lists, :entry_lists_by_current_user, :final_lists,:final_lists_by_current_user,  :create_entry_lists, :sign_lists, :sign_lists_by_current_user,
      :result, :result_by_current_user, :batch_update_entry_lists, :cancel, :entry_lists_field_options,
      :entry_lists_field_columns, :result_index, :result_index_by_current_user, :result_index_field_options,
      :result_index_field_columns, :has_been_published, :training, :cancelled, :completed,
      :result_evaluation, :result_evaluation_by_current_user, :update_result_evaluation,
      :create_training_papers, :create_student_evaluations, :create_supervisor_assessment,
      :sign_lists_field_columns, :sign_lists_field_options,
      :final_lists_field_columns, :final_lists_field_options, :entry_lists_with_to_confirm
  ]
  before_action :set_department, only:[:train_entry_lists]
  before_action :set_train_template, only: [:create]

  before_action :set_user, only: [:trains_info_by_user, :get_training_absentees_status]
  before_action :myself?, only:[:trains_info_by_user ], if: :entry_from_mine?

  def get_training_absentees_status
    render json: TrainingAbsentee.get_user_status(@user)
  end

  def create_training_papers
    authorize Train
    render json: TrainingPaper.create_papers_by_train(@train, current_user)
  end

  def create_student_evaluations
    authorize Train
    render json: StudentEvaluation.create_student_evaluations_by_train(@train, params[:questionnaire_template_id], current_user)
  end

  def create_supervisor_assessment
    authorize Train
    render json: SupervisorAssessment.create_supervisor_assessment_by_train(@train, params[:questionnaire_template_id], current_user)
  end

  def trains_info_by_user
    authorize(Train) unless entry_from_mine?
    render json: TrainingService.train_info(@user)
  end

  def cancel
    authorize Train
    response_json @train.update(status: 'cancelled')
  end

  def columns
    render json: Train.statement_columns
  end

  def options
    render json: Train.options
  end

  def create
    train_id = Train.create_with_params(
        train_final_params(params.permit(*Train.create_params)),
        params[:titles]&.map { |item| item.permit(*Title.create_params) },
        params[:train_classes], params[:positions], params[:departments], params[:locations],
        params[:users_by_invite], current_user.id, @train_template
    )
    response_json train_id
  end

  #1.首先支持：培训－列表页; 2.再支持：培训－列表页（我）
  def index
    sort_column = sort_column_sym(final_sort_column(params[:sort_column], 'Train'), :created_at)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = train_list_search_query.by_order(sort_column, sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(10)
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
            sort_column: sort_column.to_s,
            sort_direction: sort_direction.to_s,
            all_train_count: Train.count,
            not_published: Train.not_publish_count,
            has_been_published: Train.has_been_published_count,
            signing_up: Train.signing_up_count,
            registration_ends: Train.registration_ends_count,
            training: Train.training_count,
            completed: Train.completed_count,
            cancelled: Train.cancelled_count
        }
        data = query.as_json(
            include: {train_template_type: {}},
            methods: [:entry_lists_count, :final_lists_count, :train_template]
        )
        response_json data, meta: meta
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        over_time_export_num = Rails.cache.fetch('train_all_export_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('train_all_export_tag', over_time_export_num+1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t self.controller_name + '.train_class'}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns_base, options: JSON.parse(model.options.to_json), serializer: 'TrainForAllIndexSerializer', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def entry_lists_with_to_confirm
    params[:not_registration_status] = %w(cancel_the_registration invitation_to_be_confirmed)
    self.entry_lists
  end

  def entry_lists_by_current_user
    raw_entry_lists
  end


  def raw_entry_lists
    sort_column = sort_column_sym(final_sort_column(params[:sort_column], 'EntryListsByTrain'), :registration_time)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = entry_lists_search_query.by_order(sort_column, sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1))
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
          limit_number: @train.limit_number,
          titles: @train.titles&.map do |title|
            title.as_json.merge({
                                  total_count:  EntryList.joins(:title).by_title_id(title.id),
                                  attend_count: EntryList.joins(:title).by_title_id_with_attend(title.id)
                                })
          end,
          total_count_in_all_titles: EntryList.all.by_train_id(@train.id).count,
          attend_count_in_all_titles: EntryList.all.by_train_id_with_attend(@train.id).count
        }
        data = query.as_json(include: {
          title:{include: :train_classes},
          user: {include: [:department, :position]},
          creator: {include: [:department, :position]}
        })
        response_json data, meta: meta
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        export_num = Rails.cache.fetch('entry_lists_by_train_export_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+export_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('entry_lists_by_train_export_tag', export_num+1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{@train.try(select_language)}(#{@train.train_number})#{@train.train_date_begin.strftime('%Y/%m/%d')}~#{@train.train_date_end.strftime('%Y/%m/%d')}_#{I18n.t 'entry_lists_by_train.entry_list'}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: 'entry_lists', statement_columns: EntryList.statement_columns_base('entry_lists_by_train'), options: JSON.parse(EntryList.options('entry_lists_by_train', @train.id).to_json), serializer: 'EntryListByTrainSerializer', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def entry_lists
    #authorize Train
    raw_entry_lists
  end

  def create_entry_lists
    authorize Train
    params['_json'].each {|user_id|
      EntryList.create_with_params(user_id, nil, 'by_invited', current_user.id, @train.id) rescue nil
    }
    response_json
  end


  def final_lists_by_current_user
    raw_final_lists
  end


  def raw_final_lists
    sort_column = sort_column_sym(final_sort_column(params[:sort_column], 'FinalListsByTrain'), :created_at)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = final_lists_search_query.by_order(sort_column, sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1))
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
        }
        data = query.as_json(include: {
          user: {include: [:department, :position]}, train_classes: {include: :title}
        })
        response_json data, meta: meta
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        over_time_export_num = Rails.cache.fetch('final_lists_export_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('final_lists_export_tag', over_time_export_num+1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{@train.try(select_language)}(#{@train.train_number})#{@train.train_date_begin.strftime('%Y/%m/%d')}~#{@train.train_date_end.strftime('%Y/%m/%d')}_#{I18n.t 'final_lists_by_train.final_list'}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: 'final_lists', statement_columns: FinalList.statement_columns_base('final_lists_by_train', @train.id), options: JSON.parse(FinalList.options('final_lists_by_train', @train.id).to_json), serializer: 'FinalListByTrainSerializer', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def final_lists
    #authorize Train
    raw_final_lists
  end


  def raw_sign_lists

    sort_column = sort_column_sym(final_sort_column(params[:sort_column], 'FinalListsByTrain'), :created_at)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = sign_lists_search_query.by_order(sort_column, sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1))
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
        }
        data = query.as_json(include: {
          user: {include: [:department, :position]}, train_class: {include: :title}
        })
        response_json data, meta: meta
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        over_time_export_num = Rails.cache.fetch('sign_lists_export_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('sign_lists_export_tag', over_time_export_num+1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{@train.try(select_language)}(#{@train.train_number})#{@train.train_date_begin.strftime('%Y/%m/%d')}~#{@train.train_date_end.strftime('%Y/%m/%d')}_#{I18n.t 'sign_lists_by_train.sign_list'}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: 'sign_lists', statement_columns: SignList.statement_columns_base('sign_lists_by_train'), options: JSON.parse(SignList.options('sign_lists_by_train', @train.id).to_json), serializer: 'SignListByTrainSerializer', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def sign_lists_by_current_user
    raw_sign_lists
  end

  def  sign_lists
    #authorize Train
    raw_sign_lists
  end


  def introduction_by_current_user
    raw_introduction
  end

  def raw_introduction
    response_json @train.introduction, {meta: {
      has_run_tp: @train.has_run_tp,
      has_run_se: @train.has_run_se,
      has_run_sa: @train.has_run_sa,
      has_run_fl: @train.has_run_fl
    }}
  end

  def introduction
    #authorize Train
    raw_introduction
  end


  def raw_train_classes
    response_json @train.train_classes.as_json(include: :title), {meta: {
      train_place: @train.train_place,
      train_class_max_row: @train.train_classes.maximum(:row)
    }}
  end

  def train_classes_by_current_user
    raw_train_classes
  end

  def train_classes
    #authorize Train
    raw_train_classes
  end

  def classes
    response_json @train.as_json(include: [:titles, train_classes: {include: :title}])
  end

  def titles
    response_json @train.titles
  end


  def online_materials_by_current_user
    raw_online_materials
  end

  def raw_online_materials
    response_json @train.online_materials.as_json(include: :creator)
  end

  def online_materials
    #authorize Train
    raw_online_materials
  end

  #员工参加培训明细
  def all_trains
    authorize Train
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query_all_trains.order_by(sort_column,sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
        }
        render json: query, status: 200, root: 'data', meta: meta, each_serializer: UserForAllTrainsSerializer, include: '**'
      }

      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        all_trains_num = Rails.cache.fetch('all_trains_number_tag', :expires_in => 24.hours) do
          1
        end

        export_id = ( "0000"+all_trains_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('all_trains_number_tag', all_trains_num + 1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t 'all_trains.file_name'}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateAllTrainsTableJob.perform_later(query_ids:  query.ids, query_model: 'User', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  #员工参加培训明细columns
  def columns_by_all_trains
    columns = [
        {key: 'empoid',             chinese_name: '員工編號',  english_name: 'ID',   simple_chinese_name: '员工编号'},
        {key: 'name',               chinese_name: '員工姓名',  english_name: 'Name',       simple_chinese_name: '员工姓名'},
        {key: 'department_id',      chinese_name: '部門',     english_name: 'Department', simple_chinese_name: '部门'   },
        {key: 'position_id',        chinese_name: '職位',     english_name: 'Position',   simple_chinese_name: '职位'   },
        {key: 'date_of_employment', chinese_name: '入職日期',  english_name: 'Entry date', simple_chinese_name: '入职日期'},
    ]
    Train.all.where(status: :completed).order(id: :asc).each{ |train|
      column = Hash.new
      column['key'] = "#{train.id}"
      column['chinese_name'] = "#{train.chinese_name}(#{train.train_number})/#{train.train_template_chinese_name}"
      column['english_name'] = "#{train.english_name}(#{train.train_number})/#{train.train_template_english_name}"
      column['simple_chinese_name'] = "#{train.simple_chinese_name}(#{train.train_number})/#{train.train_template_simple_chinese_name}"
      columns.push column
    }

    render json: columns
  end

  def update
    authorize Train
    result = @train.update_with_params(train_final_params(params.permit(*Train.create_params)),
                                       params[:locations], params[:positions], params[:departments],
                                       params[:titles]&.map { |item| item.permit(*Title.create_params) },
                                       params[:train_classes])
    if result
      render json: result
    else
      render json: result, status: :unprocessable_entity
    end
  end

  def batch_update_entry_lists
    ActiveRecord::Base.transaction do
      update_tag ,create_tag = 0,0
      params['_json']&.each do |hash|
        entry_list = EntryList.where(user_id: hash[:id], train_id: @train.id).first rescue nil
        if entry_list
          entry_list.destroy
          entry_list = EntryList.create_with_params_by_department(hash[:id], hash[:title_id], current_user.id, @train.id, hash[:change_reason])
          if entry_list
            update_tag += 1
          end
        else
          entry_list = EntryList.create_with_params_by_department(hash[:id], hash[:title_id], current_user.id, @train.id, hash[:change_reason])
          if  entry_list
            create_tag += 1
          end
        end
      end
      response_json({update_tag: update_tag, create_tag: create_tag})
    end
  end

  #培训记录按部门
  def records_by_departments
    authorize Train
    query = TrainRecord.join_train
    respond_to do |format|
      format.json {
        final_query = []
        department_names = []
        query_id = []
        id = 1
        query.find_each do |record|
          unless department_names.include? record.department_chinese_name
            department_names.push record.department_chinese_name
            query_id.push record.id
          end
        end
        query_id.each do |key|
          row = Hash.new
          row['id'] = id
          id += 1
          record = TrainRecord.find(key)
          department_chinese_name = record.department_chinese_name
          department_english_name = record.department_english_name
          department_simple_chinese_name = record.department_simple_chinese_name
          department = {}
          department['chinese_name'] = department_chinese_name
          department['english_name'] = department_english_name
          department['simple_chinese_name'] = department_simple_chinese_name
          row['department'] = department
          department_name = record["department_#{select_language.to_s}"]
          query_each = query.where("department_#{select_language.to_s}" => department_name)
          train_id = []
          total_cost = 0
          total_attendance_rate = 0
          total_pass_rate = 0
          query_each.each do |q|
            total_cost += q.train.train_cost unless q.train.train_cost.to_s == 'NaN'
            total_attendance_rate += q.attendance_rate unless q.attendance_rate.to_s == 'NaN'
            if q.train_result
              total_pass_rate += 1
            end
            unless train_id.include? q.train_id
              train_id.push q.train_id
            end
          end
          row['train_times'] = train_id.length.to_s
          row['total_train_times'] = query_each.count.to_s
          row['total_train_costs'] = total_cost.round.to_s
          if query_each.count == 0
            row['average_train_costs'] = "0"
            row['average_attendance_rate'] = "0%"
            row['average_pass_rate'] = "0%"
          else
            row['average_train_costs'] = (total_cost / query_each.count).round.to_s
            row['average_attendance_rate'] = "#{(total_attendance_rate * 100 / query_each.count).round }%"
            row['average_pass_rate'] = "#{total_pass_rate * 100 / query_each.count }%"
          end
          final_query.push row
        end
        data = final_query.as_json
        response_json data
      }

      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        records_by_departments_num = Rails.cache.fetch('records_by_departments_number_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+records_by_departments_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('records_by_departments_number_tag', records_by_departments_num + 1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t 'records_by_departments.file_name'}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateRecordsByDepartmentsTableJob.perform_later(query_ids:  query.ids, query_model: 'TrainRecord', my_attachment: my_attachment)
        render json: my_attachment
      }

      end
  end


  def result_by_current_user
    raw_result
  end


  def raw_result
    response_json StudentEvaluation.result(StudentEvaluation.where(train_id: @train.id))
  end

  def result
    authorize Train
    raw_result
  end


  def result_index_by_current_user
    raw_result_index
  end


  def raw_result_index
    sort_column = sort_column_sym(params[:sort_column], :created_at)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    respond_to do |format|
      format.json {
        query = StudentEvaluation.query(
          queries: query_params('student_evaluations', @train.id),
          sort_column: sort_column,
          sort_direction: sort_direction,
          page: params.fetch(:page, 1),
          per_page: 20,
          path_param: @train.id,
          special_table_name:'student_evaluations'
        )
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
        }
        data = query.as_json(
          include: {
            user: {
              include: [:department, :position]
            },
            questionnaire: {
              include: [:fill_in_the_blank_questions, :choice_questions, matrix_single_choice_questions:{include: :matrix_single_choice_items } ]
            }
          }
        )
        response_json data, meta: meta
      }
      format.xlsx {
        query = StudentEvaluation.query(
          queries: query_params('student_evaluations', @train.id),
          sort_column: sort_column,
          sort_direction: sort_direction,
          page: params.fetch(:page, 1),
          per_page: 20,
          path_param: @train.id,
          special_table_name:'student_evaluations'
        )
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        over_time_export_num = Rails.cache.fetch('train_result_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('train_result_tag', over_time_export_num+1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{Time.zone.now.strftime('%Y%m%d-%H%M%s')}_#{I18n.t 'student_evaluations' + '.student_evaluation'}_#{export_id}.xlsx")
        GenerateStatementReportJob.perform_later(query_ids: query.map{|item| item.id}, query_model: 'student_evaluations', statement_columns: StudentEvaluation.statement_columns_base('student_evaluations', @train.id).map{|item| item.with_indifferent_access()}, options: JSON.parse(StudentEvaluation.options('student_evaluations', @train.id).to_json), serializer: 'StudentEvaluationForTrainSerializer', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def result_index
    authorize Train
    raw_result_index
  end

  def result_index_field_options
    render json: StudentEvaluation.options('student_evaluations', @train.id)
  end

  def result_index_field_columns
    render json: StudentEvaluation.statement_columns('student_evaluations', @train.id)
  end

  def sign_lists_field_columns
    render json: SignList.statement_columns('sign_lists_by_train', @train.id)
  end

  def  sign_lists_field_options
    render json: SignList.options('sign_lists_by_train', @train.id)
  end

  def final_lists_field_columns
    render json: FinalList.statement_columns('final_lists_by_train', @train.id)
  end

  def final_lists_field_options
    render json: FinalList.options('final_lists_by_train', @train.id)
  end


  def train_entry_lists
    query_result = User.by_entry_list(@department.users.left_outer_joins(:entry_lists),params[:train_id])
    meta = {
        limit_number: query_result[:limit_number],
        titles: query_result[:titles],
        total_count_in_all_titles: query_result[:total_count_in_all_titles],
        department_count_in_all_titles: query_result[:department_count_in_all_titles]
    }
    response_json @department.users_entry_lists(params[:train_id]), meta: meta
  end

  #培训记录按部门columns
  def columns_by_records_by_departments
    render json: [
        {key: 'department',             chinese_name: '部門',           english_name: 'Department',                  simple_chinese_name: '部门'},
        {key: 'train_times',            chinese_name: '培訓次數',        english_name: 'Times of trainingName',       simple_chinese_name: '培训次数'},
        {key: 'total_train_times',      chinese_name: '參加培訓員工總次數',english_name: 'Total times of training',     simple_chinese_name: '参加培训员工总次数'},
        {key: 'total_train_costs',      chinese_name: '培訓總費用',      english_name: 'Total training costs',        simple_chinese_name: '培训总费用'},
        {key: 'average_train_costs',    chinese_name: '員工平均培訓費用', english_name: 'Staff average training costs',simple_chinese_name: '员工平均培训费用'},
        {key: 'average_attendance_rate',chinese_name: '員工平均出席率',   english_name: 'Staff average attendance',    simple_chinese_name: '员工平均出席率'},
        {key: 'average_pass_rate',      chinese_name: '員工平均通過率',   english_name: 'Staff average passing rate',  simple_chinese_name: '员工平均通过率'},
    ]
  end

  #员工参加培训明细筛选项
  def field_options_by_all_trains
    response_json User.field_options_all_trains
  end

  #搜索员工筛选项
  def field_options_by_get_user
    response_json User.field_options_get_user
  end

  #全部记录筛选项
  def field_options_by_all_records
    response_json TrainRecord.field_options_all_records
  end

  #搜索员工
  def get_user
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query_get_user.order_by(sort_column,sort_direction)
    respond_to do |format|
      format.json {
        data = query.as_json(
          include: [:department, :position, :location, :profile],
          methods: [:division_of_job]
        )
        response_json data
      }
    end
  end

  #全部记录
  def all_records
    authorize Train
    ex_query = search_query_all_records.order("trains.train_date_begin DESC, empoid ASC")
    if params[:sort_column] && params[:sort_direction]
      sort_column = params[:sort_column].to_sym
      sort_direction = params[:sort_direction].to_sym
      query = ex_query.order_by(sort_column, sort_direction)
    else
      query = ex_query
    end

    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
        }
        data = query.as_json(include: {train: {only: [:id, :chinese_name, :english_name, :simple_chinese_name, :train_number, :train_date_begin, :train_date_end, :train_cost],
                                               methods: :train_template }})
        data.each do |record|
          department = {}
          position = {}
          department['chinese_name'] = record['department_chinese_name']
          department['english_name'] = record['department_english_name']
          department['simple_chinese_name'] = record['department_simple_chinese_name']
          position['chinese_name'] = record['position_chinese_name']
          position['english_name'] = record['position_english_name']
          position['simple_chinese_name'] = record['position_simple_chinese_name']

          record['department'] = department
          record['position'] = position
        end
        response_json data, meta: meta
      }

      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        all_records_num = Rails.cache.fetch('final_lists_number_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+ all_records_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('final_lists_number_tag', all_records_num + 1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t 'all_records.file_name'}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateAllRecordsTableJob.perform_later(query_ids:  query.ids, query_model: 'TrainRecord', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  #全部记录columns
  def columns_by_all_records
    render json: [
        {key: 'empoid',         chinese_name: '員工編號',  english_name: 'ID',          simple_chinese_name: '员工编号'},
        {key: 'name',           chinese_name: '員工姓名',  english_name: 'Name',              simple_chinese_name: '员工姓名'},
        {key: 'department',     chinese_name: '部門',     english_name: 'Department',        simple_chinese_name: '部门'},
        {key: 'position',       chinese_name: '職位',     english_name: 'Position',          simple_chinese_name: '职位'},
        {key: 'train_name',     chinese_name: '培訓名稱',  english_name: 'Training name',     simple_chinese_name: '培训名称'},
        {key: 'train_number',   chinese_name: '培訓編號',  english_name: 'Training number',   simple_chinese_name: '培训编号'},
        {key: 'date_of_train',  chinese_name: '培訓日期',  english_name: 'Training date',     simple_chinese_name: '培训日期'},
        {key: 'train_type',     chinese_name: '培訓種類',  english_name: 'Training category', simple_chinese_name: '培训种类'},
        {key: 'train_cost',     chinese_name: '培訓費用',  english_name: 'Training costs',    simple_chinese_name: '培训费用'},
        {key: 'attendance_rate',chinese_name: '出席率',    english_name: 'Attendance rate',   simple_chinese_name: '出席率'},
        {key: 'train_result',   chinese_name: '培訓結果',  english_name: 'Training result',   simple_chinese_name: '培训结果'},
    ]
  end

  def field_options
    response_json Train.field_options
  end

  def entry_lists_field_options
    render json: EntryList.options('entry_lists_by_train', @train.id)
  end

  def entry_lists_field_columns
    render json: EntryList.statement_columns('entry_lists_by_train')
  end

  def options_for_create_train
    response_json Train.create_options
  end


  def result_evaluation_by_current_user
    raw_result_evaluation
  end

  def raw_result_evaluation
    render json: @train.result_evaluation
  end


  def result_evaluation
    authorize Train
    raw_result_evaluation
  end

  def update_result_evaluation
    authorize Train
    render json: @train.update(satisfaction_percentage: params[:satisfaction_percentage])
  end

  def has_been_published
    authorize Train
    render json: @train.excute_publish
  end

  def training
    render json: @train.training
  end

  def cancelled
    authorize Train
    render json: @train.cancelled(params[:reason])
  end

  def completed
    authorize Train
    render json: @train.completed
  end

  private

  def set_train_template
    @train_template = TrainTemplate.find(params[:train_template_id])
  end

  def set_user
    @user = User.find(params[:id])
  end

  def final_lists_search_query
    @train.final_lists.joins_for_show
        .by_empoid(params[:empoid])
        .by_name(params[:name])
        .by_department_id(params[:department_id])
        .by_position_id(params[:position_id])
        .by_working_status(params[:working_status])
        .by_cost(params[:cost])
        .by_train_result(params[:train_result])
        .by_attendance_percentage(params[:attendance_percentage])
        .by_test_score(params[:test_score])
  end



  def entry_lists_search_query
    registration_time_begin = Time.zone.parse(params[:registration_time_begin]).beginning_of_day rescue nil
    registration_time_end = Time.zone.parse(params[:registration_time_end]).end_of_day rescue nil

    @train.entry_lists.joins_for_show
        .by_registration_time(registration_time_begin,registration_time_end)
        .by_empoid(params[:empoid])
        .by_name(params[:name])
        .by_department_id(params[:department_id])
        .by_position_id(params[:position_id])
        .by_is_can_be_absent(params[:is_can_be_absent])
        .by_working_status(params[:working_status])
        .by_title_id(params[:title_id])
        .by_is_in_working_time(params[:is_in_working_time])
        .by_registration_status(params[:registration_status])
        .by_creator_name(params[:creator_name])
        .by_creator_department_id(params[:creator_department_id])
        .by_creator_position_id(params[:creator_position_id])
        .by_not_registration_status(params[:not_registration_status])
  end

  def sign_lists_search_query
    @train.sign_lists.joins_for_show
        .by_empoid(params[:empoid])
        .by_name(params[:name])
        .by_department_id(params[:department_id])
        .by_position_id(params[:position_id])
        .by_title_id(params[:title_id])
        .by_train_class_id(params[:train_class_id])
        .by_working_status(params[:working_status])
        .by_sign_status(params[:sign_status])
  end


  def search_query_all_trains
    query = User.join_department_position_profile
    {
        empoid: :by_empoid,
        name: :by_name,
        department_id: :by_department_id,
        position_id: :by_position_id,
    }.each do |key, value|
      query = query.send(value, params[key]) if params[key]
    end

    date_of_employment_begin = params[:date_of_employment][:begin].to_date.beginning_of_day rescue nil
    date_of_employment_end = params[:date_of_employment][:end].to_date.end_of_day rescue nil
    if date_of_employment_begin && date_of_employment_end
      query = query.by_date_of_employment(date_of_employment_begin, date_of_employment_end)
    end

    query

  end

  def search_query_get_user
    query = User.join_department_position_profile
    {
        department_id: :by_department_id,
        position_id: :by_position_id,
        grade: :by_grade,
        division_of_job: :by_division_of_job,
    }.each do |key, value|
      query = query.send(value, params[key]) if params[key]
    end
    query
  end

  def train_list_search_query
    train_date_begin = Time.zone.parse(params[:train_date_begin]).beginning_of_day rescue nil
    train_date_end = Time.zone.parse(params[:train_date_end]).end_of_day rescue nil

    registration_date_begin = Time.zone.parse(params[:registration_date_begin]).beginning_of_day rescue nil
    registration_date_end = Time.zone.parse(params[:registration_date_end]).end_of_day rescue nil
    case params[:query_method]
      when 'by_mine'
        show_trains(current_user).joins_train_template_and_train_template_type
            .by_status(params[:status])
            .by_train_date(train_date_begin, train_date_end)
            .by_registration_date(registration_date_begin, registration_date_end)
            .by_registration_method(params[:registration_method])
            .by_train_template_type_id(params[:train_template_type_id])
            .by_training_credits(params[:training_credits])
            .by_online_or_offline_training(params[:online_or_offline_training])

      when 'by_department'
        unless TrainPolicy.new(current_user, Train).index_by_department?
          raise Pundit::NotAuthorizedError
        end
        show_trains_in_department(current_user.department_id).joins_train_template_and_train_template_type
            .by_status(params[:status])
            .by_train_date(train_date_begin, train_date_end)
            .by_registration_date(registration_date_begin, registration_date_end)
            .by_registration_method(params[:registration_method])
            .by_train_template_type_id(params[:train_template_type_id])
            .by_training_credits(params[:training_credits])
            .by_online_or_offline_training(params[:online_or_offline_training])

    else
      unless TrainPolicy.new(current_user, Train).index?
        raise Pundit::NotAuthorizedError
      end
        Train.joins_train_template_and_train_template_type
            .by_status(params[:status])
            .by_train_date(train_date_begin, train_date_end)
            .by_registration_date(registration_date_begin, registration_date_end)
            .by_registration_method(params[:registration_method])
            .by_train_template_type_id(params[:train_template_type_id])
            .by_training_credits(params[:training_credits])
            .by_online_or_offline_training(params[:online_or_offline_training])

    end

  end

  def set_train
    @train = Train.find(params[:id])
  end

  def search_query_all_records
    query = TrainRecord.join_train_train_template_train_template_type
    {
        empoid: :by_empoid,
        name: :by_name,
        department: :by_department_name,
        position: :by_position_name,
        train_result: :by_train_result,
        train_name: :by_train_id,
        train_number: :by_train_number,
        train_cost: :by_train_cost,
        train_type: :by_train_type,
        attendance_rate: :by_attendance_rate
    }.each do |key, value|
      query = query.send(value, params[key]) if params[key]
    end

    if params[:train_date_begin] || params[:train_date_end]
      query = query.by_date_of_train(params[:train_date_begin],params[:train_date_end])
    end

    date_of_train_begin = params[:date_of_train][:begin].to_date.beginning_of_day rescue nil
    date_of_train_end = params[:date_of_train][:end].to_date.end_of_day rescue nil
    if date_of_train_begin && date_of_train_end
      query = query.by_date_of_train(date_of_train_begin, date_of_train_end)
    end

    query
  end


  def show_trains(user)
    train_ids = TrainingService.trains_in_status1(user) + user.trains.pluck(:id) + TrainingService.trains_in_status3(user)
    Train.where(id: train_ids)
  end

  def show_trains_in_department(department_id)
    users = User.where(department_id: department_id)
    ids = TrainingService.trains_in_status1(users) + users.joins(:trains).pluck(:train_id) + TrainingService.trains_in_status3(users)
    Train.where(id: ids)
  end

  def set_department
    @department = Department.find(params[:id])
  end
end
