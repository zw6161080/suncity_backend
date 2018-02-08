class LentTemporarilyAppliesController < ApplicationController
  include LentRecordHelper
  def can_create
    result = []
    params[:lent_temporarily_items].each do  |lent_temporarily_item|
      lent_temporarily_item['deployment_type'] = 'lent'
      lent_temporarily_item['lent_begin'] = lent_temporarily_item['lent_date']
      lent_temporarily_item['lent_end'] = lent_temporarily_item['return_date']
      lent_temporarily_item['temporary_stadium_id'] = lent_temporarily_item['lent_location_id']

      lent_temporarily_item['calculation_of_borrowing'] = lent_temporarily_item['lent_salary_calculation']
      lent_temporarily_item['return_compensation_calculation'] = lent_temporarily_item['return_salary_calculation']
      lent_temporarily_item['temporary_stadium'] = lent_temporarily_item['lent_location_id']
      lent_temporarily_item['salary_calculation'] = lent_temporarily_item['calculation_of_borrowing']
      user = User.find(lent_temporarily_item['user_id'])
      result.push({result: TimelineRecordService.can_lent_record_create(lent_temporarily_item.merge(
        original_hall_id: user['location_id']
      )), params: lent_temporarily_item.merge(
        original_hall_id: user['location_id']
      )})
    end
    render json: {result: result}
  end


  def create
    authorize LentTemporarilyApply
    ActiveRecord::Base.transaction do
      apply = LentTemporarilyApply.create(apply_params)
      apply.create_approval_items(params[:approval_items])
      apply.create_attend_attachments(params[:attend_attachments], current_user)

      if params[:lent_temporarily_items]
        apply.create_lent_temporarily_items(params[:lent_temporarily_items], current_user, lent_required_array + lent_permitted_array)
      end
      response_json apply.id
    end
  end

  def show
    authorize LentTemporarilyApply
    apply = LentTemporarilyApply.find(params[:id])
    render json: apply, status: 200, root: 'data', include: '**'
  end

  private

  def apply_params
    params.require(:lent_temporarily_apply).permit(
      :region,
      :comment,
      :apply_date,
      :salary_calculation,
    )
  end

end
