module CareerRecordHelper
  # Only allow a trusted parameter "white list" through.
  def career_record_params
    params.require(career_required_array)
    params.permit(career_required_array + career_permitted_array)
  end

  def career_required_array
    [:career_begin, :user_id, :deployment_type, :salary_calculation, :company_name, :location_id, :position_id,
     :department_id, :grade, :division_of_job, :employment_status]
  end

  def career_permitted_array
    [:career_end, :trial_period_expiration_date, :deployment_instructions, :comment, :group_id]
  end

  def update_params
    params.permit(career_required_array + career_permitted_array)
  end

  def user_id_params
    params.require(:user_id)
  end

  def final_create_params(params)
    if params[:career_begin].nil?
      params.merge!({career_begin: Time.zone.now})
    end
    params
  end

end