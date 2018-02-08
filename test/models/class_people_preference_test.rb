require "test_helper"

class ClassPeoplePreferenceTest < ActiveSupport::TestCase
  def class_people_preference
    @class_people_preference ||= ClassPeoplePreference.new
  end

  def test_valid
    assert class_people_preference.valid?
  end
end
