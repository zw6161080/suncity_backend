# == Schema Information
#
# Table name: revision_histories
#
#  id                         :integer          not null, primary key
#  appraisal_questionnaire_id :integer
#  user_id                    :integer
#  content                    :text
#  revision_date              :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_revision_histories_on_appraisal_questionnaire_id  (appraisal_questionnaire_id)
#  index_revision_histories_on_user_id                     (user_id)
#
# Foreign Keys
#
#  fk_rails_937b83c00a  (appraisal_questionnaire_id => appraisal_questionnaires.id)
#  fk_rails_e0dda7aba4  (user_id => users.id)
#

class RevisionHistory < ApplicationRecord
  belongs_to :appraisal_questionnaire
  belongs_to :user
end
