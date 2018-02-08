class WelfareTemplatesController < ApplicationController
  include StatementBaseActions
  before_action :set_welfare_template, only: [:destroy, :can_be_destroy]

  def can_create
    wt = WelfareTemplate.new(welfare_template_params)
    render json: wt.validate_result.merge({errors: wt.errors})
  end

  def index_all
    render json: WelfareTemplate.all, root: 'data'
  end

  def index
    authorize WelfareTemplate
    params[:page] ||= 1
    meta = {}
    wtr_query = search_query
    wtr_query = wtr_query.page(params[:page].to_i).per(20)
    meta['total_count'] = wtr_query.total_count
    meta['total_page'] = wtr_query.total_pages
    meta['current_page'] = wtr_query.current_page
    response_json fill_result(wtr_query), meta: meta
  end


  def export
    query = search_query
    welfare_template_export_export_num = Rails.cache.fetch('welfare_template_export_export_num', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ welfare_template_export_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('welfare_template_export_export_num', welfare_template_export_export_num + 1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "福利模板_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns_base, options: JSON.parse(model.options.to_json),serializer: 'WelfareTemplateForExportSerializer', my_attachment: my_attachment, add_title: add_title)
    render json: my_attachment
  end

  def field_options
    options = {}
    template_name = select_template_name_language
    options['template_name'] = WelfareTemplate.pluck("welfare_templates.#{template_name.to_s}").uniq.sort
    response_json options
  end

  def like_field_options
    params[:template_name] ||= ""
    template_name = select_template_name_language
    wt = WelfareTemplate.select("id, welfare_templates.#{template_name.to_s}")
    if params[:department_id] && params[:position_id]
      wt = wt.where("belongs_to -> :department_id ?| array[:position_id] ", department_id: params[:department_id], position_id: params[:position_id])
      response_json wt.where("welfare_templates.#{template_name.to_s} like ?", "%"+params[:template_name]+"%").order("#{template_name.to_s}").distinct.as_json
    else
      response_json []
    end
  end

  def department_and_position_options
    options = []
    Department.all.each do |record|
      positions = []
      record.positions.each do |position|
        positions.push(position)
      end
      options.push({
                     department: record,
                     positions: positions
                   }
      )
    end
    response_json options
  end

  def create
    authorize WelfareTemplate
    wt = WelfareTemplate.create(welfare_template_params)
    wt.belongs_to = params[:belongs_to]
    wt.save
    if wt.validate
      response_json wt
    else
      response_json wt.errors.messages, error: true
    end
  end

  def show
    response_json WelfareTemplate.find(params[:id]).as_json
  end

  def find_template_for_department_and_position
    if params[:department_id] && params[:position_id]
      wt = WelfareTemplate.where("belongs_to -> :department_id ?| array[:position_id] ", department_id: params[:department_id], position_id: params[:position_id])
      response_json wt.as_json
    else
      response_json []
    end
  end

  def update
    authorize WelfareTemplate
    wt = WelfareTemplate.find(params[:id])
    wt.update(welfare_template_params)
    wt.belongs_to = params[:belongs_to]
    wt.save
    if wt.validate
      response_json wt
    else
      response_json wt.errors.messages, error: true
    end
  end

  def destroy
    authorize WelfareTemplate
    unless (WelfareRecord.where(welfare_template_id: @welfare_template.id).count > 0 || @welfare_template.belongs_to != {})
      WelfareTemplate.find(params[:id]).destroy
    end
    response_json
  end

  def can_be_destroy
    response_json !(WelfareRecord.where(welfare_template_id: @welfare_template.id).count > 0 || @welfare_template.belongs_to != {})
  end


  private

  def set_welfare_template
    @welfare_template = WelfareTemplate.find(params[:id])
  end

  def fill_result(wtr_query)
    result = wtr_query.as_json
    result.collect! do |hash|
      hash['department&position'] ||= []
      hash['belongs_to'].each do |key, values|
        positions = []
        values.each do |value|
          positions.push(Position.find(value.to_i))
        end
        hash['department&position'].push(
          {
            department: Department.find(key.to_i),
            positions: positions
          }
        )
      end

      hash['can_be_destroy'] = !(WelfareRecord.where(welfare_template_id: hash["id"]).count > 0 || hash["belongs_to"] != {})

      hash
    end
  end

  def search_query
    template_name = select_template_name_language
    WelfareTemplate.all.select("welfare_templates.*", "welfare_templates.#{template_name.to_s} as template_name")
      .by_annual_leave(params[:annual_leave])
      .by_sick_leave(params[:sick_leave])
      .by_office_holiday(params[:office_holiday])
      .by_holiday_type(params[:holiday_type])
      .by_probation(params[:probation])
      .by_notice_period(params[:notice_period])
      .by_double_pay(params[:double_pay])
      .by_reduce_salary_for_sick(params[:reduce_salary_for_sick])
      .by_provide_uniform(params[:provide_uniform])
      .by_over_time_salary(params[:over_time_salary])
      .by_force_holiday_make_up(params[:force_holiday_make_up])
      .by_salary_composition(params[:salary_composition])
      .by_template_name(params[:template_name])
      .by_position_id(params[:position_id])
      .by_department_id(params[:department_id])
      .order_by((params[:sort_column] || :created_at), (params[:sort_direction] || :desc))
  end

  def welfare_template_params
    params.require(
      :welfare_template
    ).permit(
      *WelfareTemplate.create_params
    )
  end

  def select_template_name_language
    if I18n.locale == 'zh-HK'.to_sym
      :template_chinese_name
    elsif I18n.locale == 'zh-CN'.to_sym
      :template_simple_chinese_name
    else
      :template_english_name
    end
  end

  def has_welfare_template?(department_id, position_id)
    WelfareTemplate.where("belongs_to -> :department_id ?| array[':position_id'] ", department_id: department_id, position_id: position_id).count > 0
  end
end
