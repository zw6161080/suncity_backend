# == Schema Information
#
# Table name: appraisal_overall_scores
#
#  id            :integer          not null, primary key
#  appraisal_id  :integer
#  group_A_score :decimal(5, 2)
#  group_B_score :decimal(5, 2)
#  group_C_score :decimal(5, 2)
#  group_D_score :decimal(5, 2)
#  group_E_score :decimal(5, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_appraisal_overall_scores_on_appraisal_id  (appraisal_id)
#
# Foreign Keys
#
#  fk_rails_6d06ccbbed  (appraisal_id => appraisals.id)
#

class AppraisalOverallScore < ApplicationRecord
  belongs_to :appraisal

  def get_appraisal_overall_score
    ['A', 'B', 'C', 'D', 'E'].each do |group_name|
      aq_of_group = self.appraisal.appraisal_questionnaires.where(appraisal_group: group_name)
      average_of_group = aq_of_group.collect(&:final_score).reduce(:+).to_f / aq_of_group.size
      self.update("group_#{group_name}_score": average_of_group)
    end
  end

end
