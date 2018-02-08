require "test_helper"

class AttendQuestionnaireTemplateTest < ActiveSupport::TestCase
  def attend_questionnaire_template
    @attend_questionnaire_template ||= AttendQuestionnaireTemplate.new
  end

  def test_valid
    assert attend_questionnaire_template.valid?
  end
end
