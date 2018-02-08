module TestJobTransferPolicyHelper
  def model_policy
    (model.to_s + 'Policy').constantize
  end

  def model

  end

  def resource
    model.to_s.to_sym
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :job_transfer, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).show?
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :job_transfer, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).create?
  end
end