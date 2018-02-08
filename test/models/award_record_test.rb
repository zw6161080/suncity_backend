require "test_helper"

class AwardRecordTest < ActiveSupport::TestCase
  test 'create' do
    test_user = create_test_user
    ar = AwardRecord.create(user_id: test_user.id, year: Time.zone.now, content: 'test', award_date: Time.zone.now, comment: 'test', creator_id: test_user.id)
    assert_equal ar.user_id, test_user.id
  end

  def award_record
    @award_record ||= AwardRecord.new
  end

  def test_valid
    assert award_record.valid?
  end
end
