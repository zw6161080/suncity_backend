# == Schema Information
#
# Table name: fill_in_the_blank_questions
#
#  id                        :integer          not null, primary key
#  questionnaire_id          :integer
#  questionnaire_template_id :integer
#  order_no                  :integer
#  question                  :text
#  answer                    :text
#  is_required               :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  value                     :integer
#  score                     :integer
#  annotation                :text
#  right_answer              :text
#  is_filled_in              :boolean
#
# Indexes
#
#  index_fill_in_the_blank_questions_on_questionnaire_id           (questionnaire_id)
#  index_fill_in_the_blank_questions_on_questionnaire_template_id  (questionnaire_template_id)
#

class FillInTheBlankQuestion < ApplicationRecord
  belongs_to :questionnaire_template
  belongs_to :questionnaire

  def self.create_params
    [:order_no, :question, :value, :score, :annotation,
     :right_answer, :is_required, :answer]
  end
end
