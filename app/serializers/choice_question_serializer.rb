class ChoiceQuestionSerializer < ActiveModel::Serializer
  attributes  *ChoiceQuestion.create_params
  has_many :options
end