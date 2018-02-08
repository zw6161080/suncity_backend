  class SalaryTemplatesController < ApplicationController
    include StatementBaseActions
  before_action :set_salary_template, only: [:destroy, :can_be_destroy]

  def export
    query = search_query
    salary_template_export_export_num = Rails.cache.fetch('salary_template_export_export_num', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ salary_template_export_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('salary_template_export_export_num', salary_template_export_export_num + 1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "薪酬模板_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns_base, options: JSON.parse(model.options.to_json),serializer: 'SalaryTemplateForExportSerializer', my_attachment: my_attachment, add_title: add_title)
    render json: my_attachment
  end

  def can_create
    wt = SalaryTemplate.new(salary_template_params)
    render json: wt.validate_result.merge({errors: wt.errors})
  end


  def index_all
    render json: SalaryTemplate.all, root: 'data'
  end

  def index
    authorize SalaryTemplate
    params[:page] ||= 1
    meta = {}
    st_query = search_query
    st_query = st_query.page( params[:page].to_i).per(20)
    meta['total_count'] = st_query.total_count
    meta['total_page'] = st_query.total_pages
    meta['current_page'] = st_query.current_page
    response_json fill_result(st_query), meta: meta
  end

  def field_options
    options = {}
    template_name = select_template_name_language
    options['template_name'] = SalaryTemplate.pluck("salary_templates.#{template_name.to_s}").uniq.sort
    response_json options
  end

  def like_field_options
    params[:template_name] ||= ""
    template_name =  select_template_name_language
    wt = SalaryTemplate.select("id, salary_templates.#{template_name.to_s}")
    if params[:department_id] && params[:position_id]
      wt =  wt.where("belongs_to -> :department_id ?| array[:position_id] ", department_id: params[:department_id], position_id: params[:position_id])
      response_json  wt.where("salary_templates.#{template_name.to_s} like ?","%"+params[:template_name]+"%").order("#{template_name.to_s}").distinct.as_json
    else
      response_json  []
    end
  end

  def create
    authorize SalaryTemplate
    wt = SalaryTemplate.new(salary_template_params)
    wt.belongs_to = params[:belongs_to]
    wt.save

    if wt.validate
      response_json wt
    else
      response_json wt.errors.messages, error: true
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

  def show
    response_json SalaryTemplate.find(params[:id]).as_json
  end

  def find_template_for_department_and_position
    if params[:department_id] && params[:position_id]
      wts =  SalaryTemplate.where("belongs_to -> :department_id ?| array[:position_id] ", department_id: params[:department_id], position_id: params[:position_id])
      response_json  wts.map{|item| item.as_json.merge( total_count: item.basic_salary+item.bonus+item.attendance_award+item.house_bonus+item.region_bonus)}
    else
      response_json  []
    end
  end

  def update
    authorize SalaryTemplate
    wt = SalaryTemplate.find(params[:id])
    wt.update(salary_template_params)
    wt.belongs_to = params[:belongs_to]
    wt.save
    if wt.validate
      response_json wt
    else
      response_json wt.errors.messages, error: true
    end
  end

  def destroy
    authorize SalaryTemplate
    unless (SalaryRecord.where(salary_template_id: @salary_template.id).count > 0 || @salary_template.belongs_to != {})
      @salary_template.destroy
    end
    response_json
  end

  def can_be_destroy
    response_json !(SalaryRecord.where(salary_template_id: @salary_template.id).count > 0 || @salary_template.belongs_to != {})
  end

  def fill_result(st_query)
    result = ActiveModelSerializers::SerializableResource.new(st_query,  each_serializer: SalaryTemplateForExportSerializer, adapter: :attributes).as_json
    result.collect! do |hash|
      hash['department&position'] ||= []
      hash['belongs_to'].each do |key,values|
        positions = []
        values.each do  |value|
          positions.push(Position.find(value.to_i))
        end
        hash['department&position'].push(
            {
                department: Department.find(key.to_i),
                positions: positions
            }
        )
      end
      hash['can_be_destroy']= !(SalaryRecord.where(salary_template_id: hash["id"]).count > 0 || hash["belongs_to"] != {})
      hash
    end
  end

  def calculate_total
    response_json SalaryTemplate.calculate_total(*calcul_total_params)
  end

  private
  def set_salary_template
    @salary_template = SalaryTemplate.find(params[:id])
  end

  def search_query
    template_name = select_template_name_language
    SalaryTemplate.all
                 .select("salary_templates.*", "salary_templates.#{template_name.to_s} as template_name")
                 .by_new_year_bonus(params[:new_year_bonus])
                  .by_project_bonus(params[:project_bonus])
                  .by_product_bonus(params[:product_bonus])
                  .by_tea_bonus(params[:tea_bonus])
                  .by_kill_bonus(params[:kill_bonus])
                  .by_performance_bonus(params[:performance_bonus])
                  .by_charge_bonus(params[:charge_bonus])
                  .by_commission_bonus(params[:commission_bonus])
                  .by_receive_bonus(params[:receive_bonus])
                  .by_exchange_rate_bonus(params[:exchange_rate_bonus])
                  .by_guest_card_bonus(params[:guest_card_bonus])
                  .by_respect_bonus(params[:respect_bonus])
                  .by_region_bonus(params[:region_bonus])
                  .by_commission_bonus(params[:commission_bonus])
                  .by_basic_salary(params[:basic_salary])
                  .by_bonus(params[:bonus])
                  .by_attendance_award(params[:attendance_award])
                  .by_house_bonus(params[:house_bonus])
                  .by_template_name(params[:template_name])
                  .by_total_count(params[:total_count])
                  .by_position_id(params[:position_id])
                  .by_department_id(params[:department_id])
                  .order_by((params[:sort_column] || :created_at), (params[:sort_direction] || :desc) )

  end

  def calcul_total_params
    res =params.permit(
        :basic_salary,
        :bonus,
        :attendance_award,
        :house_bonus,
        :basic_salary_unit,
        :bonus_unit,
        :attendance_award_unit,
        :house_bonus_unit,
    ).values
    res
  end

  def salary_template_params
    params.require(
        :salary_template
    ).permit(
       *SalaryTemplate.create_params
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

  def has_salary_template?(department_id, position_id)
    SalaryTemplate.where("belongs_to -> :department_id ?| array[:position_id] ", department_id: department_id, position_id: position_id).count > 0
  end
end
