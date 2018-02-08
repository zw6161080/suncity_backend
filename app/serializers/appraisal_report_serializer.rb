class AppraisalReportSerializer < ActiveModel::Serializer
  attributes *AppraisalReport.column_names,
             :appraisal_total_count

  belongs_to :appraisal_participator
  belongs_to :appraisal

  def appraisal_total_count
    object.appraisal_participator.assess_relationships.count - 1
  end
end
