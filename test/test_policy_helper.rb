module TestPolicyHelper
  def model_policy
    (model.to_s + 'Policy').constantize
  end

  def model

  end

  def resource
    model.to_s.to_sym
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).index?

  end

  def test_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).export_xlsx?

  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).show?
  end


  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).update?
  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).destroy?
  end


  def test_add_approval
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).add_approval?
  end

  def test_destroy_approval
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).destroy_approval?
  end

  def test_add_attach
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).add_attach?
  end

  def test_destroy_attach
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).destroy_approval?
  end
  def test_download
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).download?
  end
end