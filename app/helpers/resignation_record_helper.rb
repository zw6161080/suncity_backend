module ResignationRecordHelper
  def resignation_required_array
    [:user_id, :resigned_date, :resigned_reason, :reason_for_resignation, :employment_status, :department_id,
     :position_id, :compensation_year, :notice_period_compensation, :notice_date, :final_work_date,
     :is_in_whitelist
    ]
  end

  def resignation_permitted_array
    [:comment]
  end
end