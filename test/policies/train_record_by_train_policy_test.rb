require 'test_helper'

class TrainRecordByTrainPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_record, :train_record, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainRecordByTrainPolicy.new(user, TrainRecordByTrain).index?
  end

  def test_export
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_record, :train_record, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainRecordByTrainPolicy.new(user, TrainRecordByTrain).export?
  end

  def test_update
  end

  def test_destroy
  end
end
