require "test_helper"

class LanguageSkillTest < ActiveSupport::TestCase
  def language_skill
    @language_skill ||= LanguageSkill.new
  end

  def test_valid
    assert language_skill.valid?
  end
end
