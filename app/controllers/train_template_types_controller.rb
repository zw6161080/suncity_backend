class TrainTemplateTypesController < ApplicationController
  def index
    response_json TrainTemplateType.all
  end
  def can_be_delete
    train_template = TrainTemplateType.find(params[:id])
    has_been_used = TrainTemplate.pluck(:train_template_type_id)
    if has_been_used.include?(train_template.id)
      response_json false
    else
      response_json true
    end
  end

  def batch_update
    result = TrainTemplateType.batch_update_with_params(
                     params[:create]&.map{|item|item.permit(TrainTemplateType.create_params)},
                     params[:update]&.map{|item|item.permit(TrainTemplateType.update_params)},
                     params[:delete]
    )
    if result
      response_json
    else
      response_json nil, error: true
    end
  end
end
