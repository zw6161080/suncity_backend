# == Schema Information
#
# Table name: assess_relationships
#
#  id                        :integer          not null, primary key
#  assess_type               :string
#  appraisal_id              :integer
#  appraisal_participator_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  assessor_id               :integer
#
# Indexes
#
#  index_assess_relationships_on_appraisal_id               (appraisal_id)
#  index_assess_relationships_on_appraisal_participator_id  (appraisal_participator_id)
#  index_assess_relationships_on_assessor_id                (assessor_id)
#
# Foreign Keys
#
#  fk_rails_61a9b4c163  (appraisal_id => appraisals.id)
#  fk_rails_d7251fca69  (assessor_id => users.id)
#

class AssessRelationship < ApplicationRecord

  belongs_to :appraisal
  belongs_to :appraisal_participator
  # belongs_to :assess_participator, :class_name => 'AppraisalParticipator', :foreign_key => 'assess_participator_id'
  belongs_to :assessor, :class_name => 'User', :foreign_key => 'assessor_id'

end
