class AppraisalReportForDetailSerializer < ActiveModel::Serializer
  attributes :id,
             :overall_score,
             :count_of_assessor,
             :appraisal_participator

  def appraisal_participator
    ActiveModelSerializers::SerializableResource.new(object.appraisal_participator.user, include: '**')
  end

  def count_of_assessor
    object.appraisal_participator.assess_relationships.count - 1
  end

end
