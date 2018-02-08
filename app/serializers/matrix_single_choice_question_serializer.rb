class MatrixSingleChoiceQuestionSerializer < ActiveModel::Serializer
  attributes  *MatrixSingleChoiceQuestion.create_params,
              :id,
              :questionnaire_template_id,
              :score_of_question

  has_many :matrix_single_choice_items
end
