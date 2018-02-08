module SalaryRecordHelper
  def salary_record_params
    validate_salary_template
    params.require(salary_required_array)
    params.permit(salary_required_array + [:salary_begin, :salary_end, :salary_template_id, :comment])
  end

  def salary_required_array
    [:salary_begin,
     :user_id, :basic_salary, :bonus, :attendance_award, :house_bonus, :new_year_bonus,
     :project_bonus, :product_bonus, :tea_bonus, :kill_bonus, :performance_bonus,
     :charge_bonus, :commission_bonus, :receive_bonus,
     :exchange_rate_bonus, :guest_card_bonus,:region_bonus, :respect_bonus, :change_reason, :service_award, :internship_bonus, :performance_award, :special_tie_bonus]
  end

  def salary_permitted_array
    [:salary_end, :salary_template_id, :comment]
  end

  def user_id_params
    params.require(:user_id)
  end

  def update_params
    validate_salary_template
    required_array = [:user_id, :basic_salary, :bonus, :attendance_award,
                      :house_bonus, :new_year_bonus, :project_bonus, :product_bonus,
                      :tea_bonus, :region_bonus, :kill_bonus, :performance_bonus, :charge_bonus, :commission_bonus, :receive_bonus,
                      :exchange_rate_bonus, :guest_card_bonus, :respect_bonus, :change_reason, :service_award, :internship_bonus, :performance_award, :special_tie_bonus]
    params.permit(required_array + [:salary_begin, :salary_end, :salary_template_id, :comment])
  end

  def validate_salary_template
    if params[:salary_template_id]
      SalaryTemplate.find(params[:salary_template_id])
    end
  end
end