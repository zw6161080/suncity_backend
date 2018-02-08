class AppraisalParticipatorSerializer < ActiveModel::Serializer
  attributes :id,
             :user_id,
             :department_id,
             :location_id,
             :appraisal_group,
             :appraisal_questionnaire_template_id,
             :appraisal_grade,
             :departmental_appraisal_group,
             :assess_others,
             :superior_candidates,
             :colleague_candidates,
             :subordinate_candidates,
             :superior_assessors,
             :colleague_assessors,
             :subordinate_assessors,
             :assessors_count

  belongs_to :user, include: '**'

  def assess_others
    AssessRelationship.joins(:assessor).where(appraisal_id: object.appraisal_id).where.not(assess_type: 'self_assess').where(users: {id: object.user_id}).count
  end

  def superior_candidates
    object.candidate_relationships.where(assess_type: 'superior_assess').map do |candidate|
      candidate.candidate_participator.user.as_json(include: [:department, :location, :position])
    end
  end

  def colleague_candidates
    object.candidate_relationships.where(assess_type: 'colleague_assess').map do |candidate|
      candidate.candidate_participator.user.as_json(include: [:department, :location, :position])
    end
  end

  def subordinate_candidates
    object.candidate_relationships.where(assess_type: 'subordinate_assess').map do |candidate|
      candidate.candidate_participator.user.as_json(include: [:department, :location, :position])
    end
  end

  def superior_assessors
    object.assess_relationships.where(assess_type: 'superior_assess').map do |candidate|
      candidate.assessor.as_json(include: [:department, :location, :position])
    end
  end

  def colleague_assessors
    object.assess_relationships.where(assess_type: 'colleague_assess').map do |candidate|
      candidate.assessor.as_json(include: [:department, :location, :position])
    end
  end

  def subordinate_assessors
    object.assess_relationships.where(assess_type: 'subordinate_assess').map do |candidate|
      candidate.assessor.as_json(include: [:department, :location, :position])
    end
  end

  def assessors_count
    counts = object.assess_relationships
    {
        superior_assessors_count: counts.where(assess_type: 'superior_assess').count,
        colleague_assessors_count: counts.where(assess_type: 'colleague_assess').count,
        subordinate_assessors_count: counts.where(assess_type: 'subordinate_assess').count
    }
  end

end
