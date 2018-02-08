class ContractsController < ApplicationController
  before_action :set_applicant_position, except: :statuses

  def index
    result = @applicant_position.contracts.as_json

    response_json result
  end

  def statuses
    statuses = Contract.statuses

    response_json statuses
  end

  def create
    contract = @applicant_position.contracts.create(contract_params)
    LogService.new(:contract_created, current_user, contract).save_log(@applicant_position) if contract
    response_json
  end

  def update
    contract = @applicant_position.contracts.find(params[:id])
    contract.assign_attributes(contract_params)
    changes = contract.changes
    result = contract.save

    LogService.new(:contract_updated, current_user, contract, changes).save_log(@applicant_position) if result

    response_json result
  end

  private

  def set_applicant_position
    @applicant_position = ApplicantPosition.find(params[:applicant_position_id])
  end

  def contract_params
    params.permit(:status, :comment, :time, :cancel_reason)
  end
end
