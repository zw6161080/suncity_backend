# coding: utf-8
class PassEntryTrialsController < ApplicationController
  include FormedProfileUpdatedParamsHelper
  include SalaryRecordHelper
  include CareerRecordHelper

  def can_create
    render json: {result: TimelineRecordService.can_career_record_create(params[:new_career_record].merge(user_id: params[:user_id])), params: params[:new_career_record].merge(user_id: params[:user_id]), user: User.find(params[:user_id])}
  end

  def create
    authorize PassEntryTrial
    result = TimelineRecordService.can_career_record_create(params[:new_career_record].merge(user_id: params[:user_id]))
    raise '不符合创建规则' unless result
    ActiveRecord::Base.transaction do
      pass_entry_trial = PassEntryTrial.create!(pass_entry_trial_params)
      pass_entry_trial.create_approval_items(params[:approval_items])
      pass_entry_trial.create_attend_attachments(params[:attend_attachments], current_user)
      aq = pass_entry_trial.create_assessment_questionnaire!(region: params[:region])
      user = User.find(params[:user_id])
      pass_entry_trial.save_salary_record(user)
      pass_entry_trial.create_questionnaire_items(user, aq, params[:questionnaire_items], params[:region])
      if params[:new_career_record] && pass_entry_trial.result
        create_career_record(user)
      end
      if params[:new_salary_record]
        create_salary_record(user, pass_entry_trial)
      end
      pass_entry_trial.create_job_transfer(user,current_user,params[:new_career_record].permit(career_required_array + career_permitted_array),
                                           salary_calculation: params['salary_calculation'],
                                           transfer_type: :pass_entry_trial,
                                           apply_result: pass_entry_trial.result,
                                           write_new_career_to_jt: pass_entry_trial.result
      )
      response_json pass_entry_trial.id
    end
  end

  def show
    authorize PassEntryTrial
    pass_entry_trial = PassEntryTrial.find(params[:id])
    render json: pass_entry_trial, status: 200, root: 'data', include: '**'
  end

  private
  def create_career_record(user)
    new_row = params[:new_career_record].permit(career_required_array + career_permitted_array)
    new_row = new_row.merge inputer_id: current_user.id, user_id: user.id, deployment_type: 'through_the_probationary_period'
    CareerRecord.create!(new_row)
  end



  def create_salary_record(user, pass_trial)
    new_row = params[:new_salary_record].permit(salary_required_array + salary_permitted_array)
    if params[:result]
      salary_begin = params[:new_career_record]&.send(:[], :career_begin) || (user.career_entry_date +
        ActiveModelSerializers::SerializableResource.new(
          user.welfare_records.by_current_valid_record_for_welfare_info.first
        ).serializer_instance.probation)
      new_row = new_row.merge change_reason: 'through_the_probationary_period',
                              salary_begin: salary_begin
    else
      new_row = new_row.merge change_reason: 'other',
                              salary_begin: (params[:new_career_record]&.send(:[], :career_begin)|| params[:trial_period_expiration_date])
    end
    sr = SalaryRecord.create!(new_row.merge(user_id: user.id))
    pass_trial.save_new_salary_record(sr)
  end

  def pass_entry_trial_params
    params.require(:pass_entry_trial).permit(
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
      :salary_template_id,
      :comment,
      :salary_calculation,
      new_salary_record: salary_required_array + salary_permitted_array,
    )
  end
end
