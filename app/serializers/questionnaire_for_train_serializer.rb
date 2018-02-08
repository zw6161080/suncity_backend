class QuestionnaireForTrainSerializer < ActiveModel::Serializer
  attributes  *Questionnaire.create_params

  has_many :fill_in_the_blank_questions
  has_many :choice_questions
  has_many :matrix_single_choice_questions

end
