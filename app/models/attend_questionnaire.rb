# == Schema Information
#
# Table name: attend_questionnaires
#
#  id               :integer          not null, primary key
#  questionnaire_id :integer
#  attachable_id    :integer
#  attachable_type  :string
#
# Indexes
#
#  a_q                                              (attachable_type,attachable_id)
#  index_attend_questionnaires_on_questionnaire_id  (questionnaire_id)
#

class AttendQuestionnaire < ApplicationRecord
  belongs_to :attachable, polymorphic: true
  belongs_to :questionnaire
end
