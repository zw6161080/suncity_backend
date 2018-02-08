class AppraisalSerializer < ActiveModel::Serializer
  attributes *Appraisal.column_names,
             :appraisal_date,
             :questionnaire_submit_once

  has_many :appraisal_attachments

  def appraisal_date
    "#{object.date_begin.strftime('%Y/%m/%d')}~#{object.date_end.strftime('%Y/%m/%d')}" if (object.date_begin && object.date_end)
  end

  def questionnaire_submit_once
    AppraisalBasicSetting.first.questionnaire_submit_once_only
  end

end
