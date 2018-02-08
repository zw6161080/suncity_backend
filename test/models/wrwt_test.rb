require "test_helper"

class WrwtTest < ActiveSupport::TestCase
  test 'create' do
    wrwt = Wrwt.create(
          user_id: create_test_user.id,
          provide_airfare: true,
          provide_accommodation: true,
          airfare_type: 'count',
          airfare_count: 1,
    )

    assert_equal Wrwt.count , 1
    assert_equal Wrwt.first.provide_airfare, true
    assert_equal Wrwt.first.airfare_type, 'count'
    assert_equal Wrwt.first.airfare_count, 1
  end

  test 'create in 2' do
    wrwt = Wrwt.create(
      user_id: test_id = create_test_user.id,
      provide_airfare: false,
      provide_accommodation: true,
    )

    assert_equal Wrwt.count , 1
    assert_equal Wrwt.first.provide_airfare, false

    wrwt = Wrwt.create(
      user_id: test_id,
      provide_airfare: false,
      provide_accommodation: true,
    )
    assert_equal Wrwt.count , 1
  end


  private
  def wrwt
    @wrwt ||= Wrwt.new
  end

  def test_valid
    assert wrwt.valid?
  end
end
