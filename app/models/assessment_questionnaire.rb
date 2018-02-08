# == Schema Information
#
# Table name: assessment_questionnaires
#
#  id                    :integer          not null, primary key
#  region                :string
#  questionnairable_type :string
#  questionnairable_id   :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_assess_ques_on_quesable_type_and_quesable_id  (questionnairable_type,questionnairable_id)
#

class AssessmentQuestionnaire < ApplicationRecord
  has_many :items, class_name: 'AssessmentQuestionnaireItem'
  belongs_to :questionnairable, polymorphic: true
end
