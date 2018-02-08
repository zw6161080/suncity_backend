module EducationInformationHelper

  def education_information_params
    params.require(education_required_array)
    params.permit(education_required_array + [:rediploma_degree_attained,:certificate_issue_date])
  end

  def education_required_array
    [:from_mm_yyyy, :to_mm_yyyy, :college_university, :educational_department, :graduate_level,:graduated,:user_id]
  end

  def education_permitted_array
    [:rediploma_degree_attained,:certificate_issue_date]
  end

  def user_id_params
    params.require(:user_id)
  end

  def update_params
    required_array = [:from_mm_yyyy, :to_mm_yyyy, :college_university, :educational_department, :graduate_level,:graduated,:user_id]
    params.permit(required_array + [:rediploma_degree_attained,:certificate_issue_date])
  end
end