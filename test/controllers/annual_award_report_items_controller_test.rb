require 'test_helper'

class AnnualAwardReportItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :annual_award, :macau)
  end
  test "should get index" do
    AnnualAwardReportItem.any_instance.stubs(:annual_award_report).returns(User.first)
    User.any_instance.stubs(:year_month).returns(Time.zone.now)
    User.any_instance.stubs(:status).returns('not_granted')
    AnnualAwardReportItem.create(user_id: (user =create_test_user).id, annual_award_report_id: 1, add_double_pay: true,
    double_pay_hkd: 19, double_pay_final_hkd:19, add_end_bonus: 19, end_bonus_hkd: 19, praise_times: 19,
                                 end_bonus_add_hkd: 19, absence_times:19, notice_times:19, lack_sign_card_times:19,
                                 punishment_times: 19, de_end_bonus_for_absence_hkd: 19, de_bonus_for_notice_hkd:19,
                                 de_end_bonus_for_late_hkd: 19, de_end_bonus_for_sign_card_hkd:19, de_bonus_total_hkd: 19,
                                 end_bonus_final_hkd: 19, present_at_duty_first_half: 19, annual_at_duty_basic_hkd:19,
                                 annual_at_duty_final_hkd: 19,de_end_bonus_for_punishment_hkd: 19, double_pay_alter_hkd: 19)
    user.update(empoid: 'Z')
    User.first.add_role(@admin_role)
    AnnualAwardReportItemsController.any_instance.stubs(:authorize).returns(true)
    AnnualAwardReportItemsController.any_instance.stubs(:current_user).returns(User.first)
    get annual_award_report_items_url({path_param: 1}), as: :json
    assert_response :success
    data = json_res['data']
    assert data.count > 0
    assert data.all? do |row|
      AnnualAwardReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end


    patch annual_award_report_item_url(AnnualAwardReportItem.first.id), params: {
      annual_award_report_item: {double_pay_alter_hkd: 300}
    }

    assert_response :success
    assert_equal AnnualAwardReportItem.first.double_pay_alter_hkd, BigDecimal(300)
    assert_equal AnnualAwardReportItem.first.double_pay_final_hkd, BigDecimal(319)


    get annual_award_report_items_url({path_param: 1, name: user.chinese_name}), as: :json

    assert_response :success

    get annual_award_report_items_url({path_param: 1, sort_column: :name, sort_direction: :desc}), as: :json

    assert_response :success

    AnnualAwardReportItem.create(user_id: (user =create_test_user).id, annual_award_report_id: 1, add_double_pay: true,
                                 double_pay_hkd: 19, double_pay_final_hkd:19, add_end_bonus: 19, end_bonus_hkd: 19, praise_times: 19,
                                 end_bonus_add_hkd: 19, absence_times:19, notice_times:19, lack_sign_card_times:19,
                                 punishment_times: 19, de_end_bonus_for_absence_hkd: 19, de_bonus_for_notice_hkd:19,
                                 de_end_bonus_for_late_hkd: 19, de_end_bonus_for_sign_card_hkd:19, de_bonus_total_hkd: 19,
                                 end_bonus_final_hkd: 19, present_at_duty_first_half: 19, annual_at_duty_basic_hkd:19,
                                 annual_at_duty_final_hkd: 19,de_end_bonus_for_punishment_hkd: 19, double_pay_alter_hkd: 19)
    user.update(empoid: 'A')
    get "#{annual_award_report_items_url}.xlsx", params: {path_param: 1}
    assert_response :success
  end



  test "should get columns" do
    AnnualAwardReportItemsController.any_instance.stubs(:current_user).returns(create_test_user)
    AnnualAwardReportItem.any_instance.stubs(:annual_award_report).returns(User.first)
    get columns_annual_award_report_items_url, as: :json
    assert_response 403
    AnnualAwardReportItemsController.any_instance.stubs(:authorize).returns(true)
    AnnualAwardReportItem.any_instance.stubs(:annual_award_report).returns(User.first)
    User.first.add_role(@admin_role)
    get columns_annual_award_report_items_url, as: :json
    assert_response :success
    assert json_res.count > 0
    assert json_res.all? do |col|
      client_attributes = Config
                            .get('report_column_client_attributes')
                            .fetch('attributes', [])
      assert col.keys.to_set.subset?(client_attributes.to_set)
    end
  end

  test "should get options" do
    AnnualAwardReportItemsController.any_instance.stubs(:authorize).returns(true)
    AnnualAwardReportItem.any_instance.stubs(:annual_award_report).returns(User.first)
    User.first.add_role(@admin_role)
    get options_annual_award_report_items_url, as: :json
    assert_response :success
    AnnualAwardReportItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end
end
