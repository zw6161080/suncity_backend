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

require 'test_helper'

class AssessmentQuestionnaireTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
