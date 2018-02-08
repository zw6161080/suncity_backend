module WorkExperenceHelper

  def work_experence_params
    params.require(work_required_array)
    params.permit(work_required_array + [:job_description,
                                         :work_experience_salary, :work_experience_reason_for_leaving, :work_experience_company_phone_number,:former_head,:work_experience_email])
  end

  def work_required_array
    [:user_id, :company_organazition, :work_experience_position, :work_experience_from, :work_experience_to]
  end

  def work_permitted_array
    [:job_description,
     :work_experience_salary, :work_experience_reason_for_leaving, :work_experience_company_phone_number,:former_head,:work_experience_email]
  end

  def user_id_params
    params.require(:user_id)
  end

  def update_params
    required_array = [:user_id, :company_organazition, :work_experience_position, :work_experience_from, :work_experience_to]
    params.permit(required_array + [:job_description,
                                    :work_experience_salary, :work_experience_reason_for_leaving, :work_experience_company_phone_number,:former_head,:work_experience_email])
  end
end