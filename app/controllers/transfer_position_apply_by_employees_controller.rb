class TransferPositionApplyByEmployeesController < ApplicationController
  include CareerRecordHelper
  include SalaryRecordHelper
  include WelfareRecordHelper

  def can_create
    render json: {result: TimelineRecordService.can_career_record_create(params[:new_career_record].merge(user_id: params[:user_id])), params: params[:new_career_record].merge(user_id: params[:user_id]), user: User.find(params[:user_id])}
  end

  def create
    authorize TransferPositionApplyByDepartment
    result = TimelineRecordService.can_career_record_create(params[:new_career_record].merge(user_id: params[:user_id]))
    raise '不符合创建规则' unless result
    ActiveRecord::Base.transaction do
      apply = TransferPositionApplyByEmployee.create!(apply_params)

      user = User.find(params[:user_id])

      # For roster_object
      should_change_roster_objects = RosterObject
                                       .where(user_id: user.id, is_active: ['active', nil])
                                       .where("roster_date >= ?", apply.transfer_date)

      should_change_roster_objects.each do |ro|
        RosterObject.create(ro.attributes.merge({
                                                  id: nil,
                                                  is_active: 'inactive',
                                                  special_type: 'transfer_position',
                                                  created_at: nil,
                                                  updated_at: nil
                                                }))

        ro.is_active= 'active'
        ro.special_type = 'transfer_position'
        ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
        ro.location_id = apply.transfer_location_id
        ro.department_id = apply.transfer_department_id
        # ro.roster_list_id = nil
        ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
        ro.save

        ro.roster_object_logs.create(modified_reason: 'transfer_position',
                                     approver_id: current_user.id,
                                     approval_time: Time.zone.now.to_datetime,
                                     class_setting_id: ro.class_setting_id,
                                     is_general_holiday: ro.is_general_holiday,
                                     working_time: ro.working_time,
                                     holiday_type: ro.holiday_type,
                                     borrow_return_type: ro.borrow_return_type,
                                     working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
                                    )
      end

      apply.create_approval_items(params[:approval_items])
      apply.create_attend_attachments(params[:attend_attachments], current_user)
      apply.create_training_courses(params[:training_courses])

      apply.save_salary_record(user)
      apply.save_welfare_record(user)
      if params[:new_career_record] && apply.is_transfer
        create_career_record(user)
      end

      if params[:new_salary_record]
        create_salary_record(user, apply)
      end

      if params[:new_welfare_record]
        create_welfare_record(user, apply)
      end
      apply.create_job_transfer(user,current_user,params[:new_career_record].permit(career_required_array + career_permitted_array),
                                     salary_calculation: params['salary_calculation'],
                                     transfer_type: "transfer_position_apply_by_employee",
                                     apply_result: apply.is_transfer,
                                     write_new_career_to_jt: apply.is_transfer
      )
      response_json apply.id
    end
  end

  def show
    authorize TransferPositionApplyByDepartment
    apply = TransferPositionApplyByEmployee.find(params[:id])
    render json: apply, status: 200, root: 'data', include: '**'
  end

  private
  def create_career_record(user)
    new_row = params[:new_career_record].permit(career_required_array + career_permitted_array)
    new_row = new_row.merge inputer_id: current_user.id, user_id: user.id, deployment_type: 'transfer_by_employee_initiated'
    CareerRecord.create!(new_row)
  end

  def create_salary_record(user, apply)
    new_row = params[:new_salary_record].permit(salary_required_array + salary_permitted_array)
    new_row = new_row.merge change_reason: 'transfer_by_employee_initiated'
    sr = SalaryRecord.create!(new_row.merge(user_id: user.id))
    apply.save_new_salary_record(sr)
  end

  def create_welfare_record(user, apply)
    new_row = params[:new_welfare_record].permit(* welfare_required_array + welfare_permitted_array)
    new_row = new_row.merge(change_reason: 'transfer_by_employee_initiated', welfare_begin: (params[:new_career_record]&.send(:[], :career_begin)|| params[:transfer_date]))
    wr = WelfareRecord.create!(new_row.merge(user_id: user.id))
    apply.save_new_welfare_record(wr)
  end

  def apply_params
    params.require(:transfer_position_apply_by_employee).permit(
      :region,
      :user_id,
      :comment,
      :apply_date,
      :apply_location_id,
      :apply_department_id,
      :apply_position_id,
      :apply_reason,
      :apply_group_id,
      :is_recommended_by_department,
      :reason,
      :is_continued,
      :interview_date_by_department,
      :interview_time_by_department,
      :interview_location_by_department,
      :interview_result_by_department,
      :interview_comment_by_department,
      :interview_date_by_header,
      :interview_time_by_header,
      :interview_location_by_header,
      :interview_result_by_header,
      :interview_comment_by_header,
      :is_transfer,
      :transfer_date,
      :transfer_location_id,
      :transfer_department_id,
      :transfer_position_id,
      :transfer_group_id,
      :salary_calculation,
      new_salary_record: salary_required_array + salary_permitted_array,
      new_welfare_record: welfare_required_array + welfare_permitted_array,
    )
  end

end
