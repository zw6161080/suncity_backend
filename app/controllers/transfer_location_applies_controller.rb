class TransferLocationAppliesController < ApplicationController
  include MuseumRecordHelper
  def can_create
    result = []
    params[:transfer_location_items].each do  |transfer_location_item|
      transfer_location_item[:date_of_employment] = transfer_location_item[:transfer_date]
      transfer_location_item[:deployment_type] = 'museum'
      transfer_location_item[:location_id] = transfer_location_item[:transfer_location_id]
      transfer_location_item[:salary_calculation] = transfer_location_item[:salary_calculation]
      result.push({result: TimelineRecordService.can_museum_record_create(transfer_location_item), params: transfer_location_item})
    end
    render json: {result: result}
  end

  def create
    authorize TransferLocationApply
    ActiveRecord::Base.transaction do
      apply = TransferLocationApply.create(apply_params)
      apply.create_approval_items(params[:approval_items])
      apply.create_attend_attachments(params[:attend_attachments], current_user)
      if params[:transfer_location_items]
        apply.create_transfer_location_items(params[:transfer_location_items], current_user, museum_required_array + museum_permitted_array )
      end
      response_json apply.id
    end
  end

  def show
    authorize TransferLocationApply
    apply = TransferLocationApply.find(params[:id])
    render json: apply, status: 200, root: 'data', include: '**'
  end

  private
  def apply_params
    params.require(:transfer_location_apply).permit(
      :region,
      :comment,
      :apply_date,
      :salary_calculation,
    )
  end
end
