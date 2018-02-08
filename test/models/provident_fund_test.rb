require 'test_helper'

class ProvidentFundTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'providnet_fund with reports' do
    @test_profile = Profile.find(create_profile_with_welfare_and_salary_template[:id])
    assert_difference('DepartureEmployeeTaxpayerNumberingReportItem.count', 1)do
    assert_difference('EmployeeRedemptionReportItem.count', 4)do
      @pf = create(:provident_fund, member_retirement_fund_number: 'number_2', is_an_american: true,
             has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: '60', a_fund_percentage: '50', b_fund_percentage: '30', profile_id: @test_profile.id , user_id: @test_profile.user_id, provident_fund_resignation_date: Time.zone.now.to_date)
    end
    end
    assert_difference('DepartureEmployeeTaxpayerNumberingReportItem.count', -1)do
      assert_difference('EmployeeRedemptionReportItem.count', -4)do
        @pf.provident_fund_resignation_date = nil
        @pf.save
      end
    end
  end
end
