# == Schema Information
#
# Table name: choice_questions
#
#  id                        :integer          not null, primary key
#  questionnaire_id          :integer
#  questionnaire_template_id :integer
#  order_no                  :integer
#  question                  :text
#  answer                    :integer          default([]), is an Array
#  is_multiple               :boolean
#  is_required               :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  value                     :integer
#  score                     :integer
#  annotation                :text
#  right_answer              :integer          default([]), is an Array
#  is_filled_in              :boolean
#
# Indexes
#
#  index_choice_questions_on_questionnaire_id           (questionnaire_id)
#  index_choice_questions_on_questionnaire_template_id  (questionnaire_template_id)
#

class ChoiceQuestion < ApplicationRecord
  belongs_to :questionnaire_template
  belongs_to :questionnaire
  has_many :options, dependent: :destroy

  def self.create_params
    [:order_no, :question, :value, :score, :annotation,
     :right_answer, :is_multiple, :is_required, :answer]
  end
end
