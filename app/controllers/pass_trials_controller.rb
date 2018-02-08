# coding: utf-8
class PassTrialsController < ApplicationController
  include CareerRecordHelper
  include SalaryRecordHelper
  def can_create
    render json: {result: TimelineRecordService.can_career_record_create(params[:new_career_record].merge(user_id: params[:user_id])), params: params[:new_career_record].merge(user_id: params[:user_id]), user: User.find(params[:user_id])}
  end

  def create
    authorize PassTrial
    result = TimelineRecordService.can_career_record_create(params[:new_career_record].merge(user_id: params[:user_id]))
    raise '不符合创建规则' unless result
    ActiveRecord::Base.transaction do
      pass_trial = PassTrial.create!(pass_trial_params)
      pass_trial.create_approval_items(params[:approval_items])
      pass_trial.create_attend_attachments(params[:attend_attachments], current_user)
      aq = pass_trial.create_assessment_questionnaire!(region: params[:region])
      user = User.find(params[:user_id])
      pass_trial.save_salary_record(user)
      pass_trial.create_questionnaire_items(user, aq, params[:questionnaire_items], params[:region])
      if params[:new_career_record] && pass_trial.result
        create_career_record(user)
      end
      if params[:new_salary_record]
        create_salary_record(user, pass_trial)
      end
      pass_trial.create_job_transfer(user,current_user,params[:new_career_record].permit(career_required_array + career_permitted_array),
                                     salary_calculation: params['salary_calculation'],
                                     transfer_type: "pass_#{pass_trial.trial_type}_trial",
                                     apply_result: pass_trial.result,
                                     write_new_career_to_jt: pass_trial.result
      )
      response_json pass_trial.id
    end
  end

  def show
    authorize PassTrial
    pass_trial = PassTrial.find(params[:id])
    render json: pass_trial, status: 200, root: 'data', include: '**'
  end

  private
  def create_career_record(user)
    new_row = params[:new_career_record].permit(career_required_array + career_permitted_array)
    if params[:trial_type] == 'transfer'
      new_row = new_row.merge deployment_type: 'through_the_transfer_probation_period'
    elsif params[:trial_type] == 'entry'
      new_row = new_row.merge deployment_type: 'entry'
    end
    new_row = new_row.merge inputer_id: current_user.id, user_id: user.id
    CareerRecord.create!(new_row)
  end

  def create_salary_record(user, pass_trial)
    new_row = params[:new_salary_record].permit(salary_required_array + salary_permitted_array)
    if params[:result]
      new_row = new_row.merge change_reason: 'through_the_transfer_probation_period',
                              salary_begin: (params[:new_career_record]&.send(:[], :career_begin)|| params[:trial_period_expiration_date])
    else
      new_row = new_row.merge change_reason: 'other',
                              salary_begin: (params[:new_career_record]&.send(:[], :career_begin)|| params[:trial_period_expiration_date])
    end
    sr = SalaryRecord.create!(new_row.merge(user_id: user.id))
    pass_trial.save_new_salary_record(sr)
  end

  def pass_trial_params
    params.require(:pass_trial).permit(
      :region,
      :user_id,
      :apply_date,
      :employee_advantage,
      :employee_need_to_improve,
      :employee_opinion,
      :result,
      :trial_expiration_date,
      :dismissal,
      :last_working_date,
      :comment,
      :trial_type,
      :salary_calculation,
      new_salary_record: salary_required_array + salary_permitted_array,
    )
  end
end
