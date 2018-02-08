require 'test_helper'

class TrainPolicyTest < ActiveSupport::TestCase



  def test_train_classes?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_record, :train_record, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).train_classes?
  end

  def test_all_trains?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_record, :train_record, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).all_trains?
  end

  def test_records_by_departments?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_record, :train_record, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).records_by_departments?
  end

  def test_all_records
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_record, :train_record, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).all_records?
  end

  def test_index?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :train, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).index?
  end

  def test_index_by_department
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).index_by_department?
  end

  def test_train_entry_lists
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).train_entry_lists?
  end

  def test_create_entry_lists
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).create_entry_lists?
  end

  def test_scope
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainPolicy.new(user, Train).introduction?
    assert TrainPolicy.new(user, Train).entry_lists?
    assert TrainPolicy.new(user, Train).online_materials?
    assert TrainPolicy.new(user, Train).final_lists?
    assert TrainPolicy.new(user, Train).sign_lists?
    assert TrainPolicy.new(user, Train).result?
    assert TrainPolicy.new(user, Train).result_index?
    assert TrainPolicy.new(user, Train).result_evaluation?
    assert TrainPolicy.new(user, Train).update_result_evaluation?
    assert TrainPolicy.new(user, Train).has_been_published?
    assert TrainPolicy.new(user, Train).update?
    assert TrainPolicy.new(user, Train).cancel?
    assert TrainPolicy.new(user, Train).create_entry_lists?
    assert TrainPolicy.new(user, Train).sign_lists?
    assert TrainPolicy.new(user, Train).create_training_papers?
    assert TrainPolicy.new(user, Train).create_student_evaluations?
    assert TrainPolicy.new(user, Train).create_supervisor_assessment?
    assert TrainPolicy.new(user, Train).completed?
    assert TrainPolicy.new(user, Train).entry_lists_with_to_confirm?
  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end
end
