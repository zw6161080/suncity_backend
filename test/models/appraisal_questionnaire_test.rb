require "test_helper"

class AppraisalQuestionnaireTest < ActiveSupport::TestCase
  def appraisal_questionnaire
    @appraisal_questionnaire ||= AppraisalQuestionnaire.new
  end

  def test_valid
    assert appraisal_questionnaire.valid?
  end
end
