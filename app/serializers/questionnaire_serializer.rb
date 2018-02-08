class QuestionnaireSerializer < ActiveModel::Serializer
  attributes *Questionnaire.column_names

  belongs_to :release_user
  belongs_to :user

  has_many :fill_in_the_blank_questions
  has_many :choice_questions
  has_many :matrix_single_choice_questions
end
