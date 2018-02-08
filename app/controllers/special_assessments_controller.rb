class SpecialAssessmentsController < ApplicationController
  include CareerRecordHelper
  include SalaryRecordHelper
  def create
    authorize SpecialAssessment
    ActiveRecord::Base.transaction do
      special_assessment = SpecialAssessment.create!(special_assessment_params)
      special_assessment.create_approval_items(params[:approval_items])
      special_assessment.create_attend_attachments(params[:attend_attachments], current_user)
      aq = special_assessment.create_assessment_questionnaire!(region: params[:region])
      user = User.find(params[:user_id])
      special_assessment.save_salary_record(user)
      special_assessment.create_questionnaire_items(user, aq, params[:questionnaire_items], params[:region])


      if params[:new_salary_record]
        create_salary_record(user, special_assessment)
      end
      special_assessment.create_job_transfer(user,current_user,nil,
                                             salary_calculation: params['salary_calculation'],
                                             transfer_type: "special_assessment",
                                             apply_result: true,
                                             write_new_career_to_jt: false
      )
      response_json special_assessment.id
    end
  end

  def show
    authorize SpecialAssessment
    special_assessment = SpecialAssessment.find(params[:id])
    render json: special_assessment, status: 200, root: 'data', include: '**'
  end

  private

  def create_salary_record(user, special_assessment)
    new_row = params[:new_salary_record].permit(salary_required_array + salary_permitted_array)
    new_row = new_row.merge change_reason: 'special_assessment'
    sr = SalaryRecord.create!(new_row.merge(user_id: user.id))
    special_assessment.save_new_salary_record(sr)
  end

  def special_assessment_params
    params.require(:special_assessment).permit(
      :region,
      :user_id,
      :apply_date,
      :employee_advantage,
      :employee_need_to_improve,
      :employee_opinion,
      :comment,
      :salary_calculation,
      new_salary_record: salary_required_array + salary_permitted_array,
    )
  end

end
