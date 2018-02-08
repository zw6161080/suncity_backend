class StudentEvaluationForTrainSerializer < ActiveModel::Serializer
  attributes  *StudentEvaluation.create_params
  has_one :user
  has_one :questionnaire, serializer: QuestionnaireForTrainSerializer
end
