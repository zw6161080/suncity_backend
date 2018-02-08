require "test_helper"

class AttendQuestionnaireTest < ActiveSupport::TestCase
  def attend_questionnaire
    @attend_questionnaire ||= AttendQuestionnaire.new
  end

  def test_valid
    assert attend_questionnaire.valid?
  end
end
