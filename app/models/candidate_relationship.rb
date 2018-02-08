# == Schema Information
#
# Table name: candidate_relationships
#
#  id                        :integer          not null, primary key
#  assess_type               :string
#  appraisal_id              :integer
#  appraisal_participator_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  candidate_participator_id :integer
#
# Indexes
#
#  index_candidate_relationships_on_appraisal_id               (appraisal_id)
#  index_candidate_relationships_on_appraisal_participator_id  (appraisal_participator_id)
#  index_candidate_relationships_on_candidate_participator_id  (candidate_participator_id)
#
# Foreign Keys
#
#  fk_rails_38e910f879  (appraisal_id => appraisals.id)
#  fk_rails_9167d51238  (candidate_participator_id => appraisal_participators.id)
#

class CandidateRelationship < ApplicationRecord

  belongs_to :appraisal
  belongs_to :appraisal_participator
  belongs_to :candidate_participator, :class_name => 'AppraisalParticipator', :foreign_key => 'candidate_participator_id'

end
