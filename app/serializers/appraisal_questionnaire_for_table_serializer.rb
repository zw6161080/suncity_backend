class AppraisalQuestionnaireForTableSerializer < ActiveModel::Serializer
  attributes *AppraisalQuestionnaire.column_names,
             :appraisal_participator

  belongs_to :appraisal
  belongs_to :assessor
  belongs_to :questionnaire

  def appraisal_participator
    object.appraisal_participator.user.as_json(include: [:location, :department, :position])
  end

end
