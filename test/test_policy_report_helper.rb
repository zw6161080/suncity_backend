module TestPolicyReportHelper
  def test_index_for_report
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).index_for_report?
  end
  def test_export_xlsx_for_report
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).export_xlsx_for_report?
  end
end
