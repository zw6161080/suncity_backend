# coding: utf-8
class MedicalItemsController < ApplicationController

  # GET /medical_items
  def index
    authorize MedicalItem
    response_json MedicalItem
                      .includes(:medical_item_template)
                      .where(medical_template_id: params[:medical_template_id])
                      .as_json(include: :medical_item_template)
  end

  # POST /medical_items
  def create
    authorize MedicalItem
    medical_item = MedicalItem.create(medical_item_params.as_json)
    response_json medical_item
  end

  # DELETE /medical_items/1
  def destroy
    authorize MedicalItem
    MedicalItem.find(params[:id]).destroy
  end

  private
    # Only allow a trusted parameter "white list" through.
    def medical_item_params
      params.require(:medical_item).permit(*MedicalItem.create_params)
    end

end
