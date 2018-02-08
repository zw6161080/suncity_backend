class MedicalItemTemplatesController < ApplicationController

  # GET /medical_item_templates
  def index
    authorize MedicalItemTemplate
    response_json search_query
  end

  # POST /medical_item_templates
  def create
    authorize MedicalItemTemplate

    created_ids = []
    params[:medical_item_template][:templates].each do |template|
      template = MedicalItemTemplate.create(template.as_json.merge(can_be_delete: true))
      created_ids += [template.id]
    end
    params[:medical_item_template][:delete_ids].each do |delete_id|
      MedicalItemTemplate.find(delete_id).destroy
    end
    response_json MedicalItemTemplate.all
  end

  private
    # Only allow a trusted parameter "white list" through.
    def medical_item_template_params
      params.require(:medical_item_template).permit(*MedicalItemTemplate.create_params)
    end

    def search_query
      query = MedicalItemTemplate.all
      query.each do |record|
        record[:can_be_delete] = true
        # 医疗模板是否存在该 medical_item
        if MedicalItem.where(medical_item_template_id: record.id).exists?
          record[:can_be_delete] = false
        end
      end
      query
    end
end
