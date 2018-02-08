# == Schema Information
#
# Table name: matrix_single_choice_questions
#
#  id                        :integer          not null, primary key
#  questionnaire_id          :integer
#  questionnaire_template_id :integer
#  order_no                  :integer
#  title                     :text
#  max_score                 :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  value                     :integer
#  score                     :integer
#  annotation                :text
#  score_of_question         :decimal(5, 2)
#
# Indexes
#
#  index_matrix_single_choice_questions_on_questionnaire_id  (questionnaire_id)
#  xxx_questionnaire_template_index                          (questionnaire_template_id)
#

class MatrixSingleChoiceQuestion < ApplicationRecord
  belongs_to :questionnaire_template
  belongs_to :questionnaire
  has_many :matrix_single_choice_items, dependent: :destroy

  def self.create_params
    [:order_no, :title, :value, :score, :annotation, :max_score]
  end
end
