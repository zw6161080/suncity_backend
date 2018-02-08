class AppraisalByMineAndDepartmentSerializer < ActiveModel::Serializer
  attributes *Appraisal.column_names, :appraisal_date, :count, :count_of_department, :ave_of_department, :ave_of_mine

  def appraisal_date
    "#{object.date_begin.strftime('%Y/%m/%d')}~#{object.date_end.strftime('%Y/%m/%d')}" if (object.date_begin && object.date_end)
  end

  def count
    object.appraisal_participators.count
  end

  def count_of_department
    object.appraisal_participators.where(department_id: @instance_options[:current_user].department_id).count
  end

  def ave_of_department
    ids = object.appraisal_participators.where(department_id: @instance_options[:current_user].department_id).ids
    reports = AppraisalReport.where(appraisal_participator_id: ids)
    score = reports.sum(:overall_score)
    (score / count_of_department).round(2)
  end

  def ave_of_mine
    object.appraisal_participators.where(user_id: @instance_options[:current_user].id).first.appraisal_report.overall_score rescue nil
  end

end