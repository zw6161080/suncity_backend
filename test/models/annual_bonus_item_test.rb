require 'test_helper'

class AnnualBonusItemTest < ActiveSupport::TestCase
  setup do
    User.destroy_all
    @test_users = [ create_test_user(100), create_test_user(102), create_test_user(103) ]
    @test_users.each do |user|
      create(:career_record, user_id: user.id, career_begin: '2010/01/01')
      create(:salary_record, user_id: user.id, salary_begin: '2010/01/01')
    end
  end

  test "should item generate" do
    event = create(:annual_bonus_event,
                   begin_date: '2016/01/01',
                   end_date: '2016/12/31',
                   settlement_date: '2016/12/31',
                   settlement_salary_year_month: '2016/12/31')
    @test_users.each do |u|
      assert AnnualBonusItem.where(user: u, annual_bonus_event: event).exists?
    end

  end
end
