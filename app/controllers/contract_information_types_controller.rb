class ContractInformationTypesController < ApplicationController

  def index
    contract_information_types = model.all.as_json(methods: [:can_delete?, :total_count])
    response_json contract_information_types
  end

  def create
    authorize ContractInformationType
    contract_information_type = model.create(params.permit(:chinese_name, :english_name, :description))
    contract_information_type.save

    response_json
  end

  def show
    contract_information_types = model.find(params[:id])
    response_json contract_information_types
  end

  def update
    authorize ContractInformationType
    contract_information_types = model.find(params[:id])
    result = contract_information_types.update_attributes(params.permit(:chinese_name, :english_name, :description))

    response_json result
  end

  def destroy
    authorize ContractInformationType
    contract_information_type = model.find(params[:id])
    contract_information_type.destroy

    response_json
  end

  private

  def model
    ContractInformationType
  end
end
