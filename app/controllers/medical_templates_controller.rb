class MedicalTemplatesController < ApplicationController

  include SortParamsHelper

  before_action :set_medical_template, only: [:show, :update, :destroy]

  # GET /medical_templates
  def index
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    current_template_ids = MedicalTemplateSetting.first['sections'].pluck('current_template_id').without(nil).uniq if MedicalTemplateSetting.first
    query = MedicalTemplate.all.order(sort_column => sort_direction)
    data = query.map do |record|
      record.get_json_data(current_template_ids)
    end
    response_json data
  end

  # GET /medical_templates/1
  def show
    authorize MedicalTemplate
    response_json @medical_template.as_json(include: { medical_items: { include: :medical_item_template}})
  end

  # GET /medical_templates/create_permission
  def create_permission
    authorize MedicalTemplate
    permission = false
    unless MedicalTemplate.where(
        'chinese_name = :chinese_name OR
           english_name = :english_name OR
           simple_chinese_name = :simple_chinese_name',
        chinese_name: medical_template_params['chinese_name'],
        english_name: medical_template_params['english_name'],
        simple_chinese_name: medical_template_params['simple_chinese_name']
    ).exists?
      permission = true
    end
    response_json permission
  end

  # POST /medical_templates
  def create
    authorize MedicalTemplate
    if MedicalTemplate.where(
        'chinese_name = :chinese_name OR
         english_name = :english_name OR
         simple_chinese_name = :simple_chinese_name',
        chinese_name: medical_template_params['chinese_name'],
        english_name: medical_template_params['english_name'],
        simple_chinese_name: medical_template_params['simple_chinese_name']
    ).exists?
      response_json [], status: :unprocessable_entity
    else
      items_data = medical_template_params.as_json['medical_items']
      medical_template = MedicalTemplate.create!(medical_template_params.as_json
                                                    .without('medical_items')
                                                    .merge(can_be_delete: true, undestroyable_forever: false, undestroyable_temporarily: false))
      items_data.each do |record|
        record['medical_template_id'] = medical_template.id
      end
      medical_template.medical_items<<MedicalItem.create(items_data)
      response_json medical_template.as_json(include: :medical_items)
    end
  end

  # PATCH/PUT /medical_templates/1
  def update
    authorize MedicalTemplate
    if (@medical_template.chinese_name==medical_template_params['chinese_name'])&&
        (@medical_template.english_name==medical_template_params['english_name'])&&
        (@medical_template.simple_chinese_name==medical_template_params['simple_chinese_name'])
      # 修改名字以外的参数，正常修改
      items_data = medical_template_params.as_json['medical_items']
      if @medical_template.update(medical_template_params.as_json.without('medical_items'))
        @medical_template.medical_items = MedicalItem.create(items_data)
        response_json @medical_template
      else
        response_json @medical_template.errors, status: :unprocessable_entity
      end
    else
      # 需要修改名字，检查是否 与其他医疗模板重名
      if MedicalTemplate.where(
          'chinese_name = :chinese_name OR
           english_name = :english_name OR
           simple_chinese_name = :simple_chinese_name',
          chinese_name: medical_template_params['chinese_name'],
          english_name: medical_template_params['english_name'],
          simple_chinese_name: medical_template_params['simple_chinese_name']
      ).where.not(id: @medical_template.id).exists?
        response_json [], status: :unprocessable_entity
      else
        items_data = medical_template_params.as_json['medical_items']
        if @medical_template.update(medical_template_params.as_json.without('medical_items'))
          @medical_template.medical_items = MedicalItem.create(items_data)
          response_json @medical_template
        else
          response_json @medical_template.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /medical_templates/1
  def destroy
    authorize MedicalTemplate
    @medical_template.destroy
    response_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medical_template
      @medical_template = MedicalTemplate.includes(:medical_items).find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def medical_template_params
      params.require(:medical_template).permit(
          *MedicalTemplate.create_params,
          medical_items: [*MedicalItem.create_params],
      )
    end
end
