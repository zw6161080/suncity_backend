class FillInTheBlankQuestionSerializer < ActiveModel::Serializer
  attributes  *FillInTheBlankQuestion.create_params
end