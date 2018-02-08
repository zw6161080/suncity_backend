# == Schema Information
#
# Table name: attend_questionnaire_templates
#
#  id                        :integer          not null, primary key
#  questionnaire_template_id :integer
#  attachable_id             :integer
#  attachable_type           :string
#
# Indexes
#
#  a_q_t               (attachable_id,attachable_type)
#  index_a_q_t_on_q_t  (questionnaire_template_id)
#

class AttendQuestionnaireTemplate < ApplicationRecord
  belongs_to :attachable, polymorphic: true
  belongs_to :questionnaire_template
end
