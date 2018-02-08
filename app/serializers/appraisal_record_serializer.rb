class AppraisalRecordSerializer < ActiveModel::Serializer
  attributes :appraisal_reports

  belongs_to :user

  def appraisal_reports
    object.get_appraisal_record_details
  end

end
