require "test_helper"

class GroupTest < ActiveSupport::TestCase
  def group
    @group ||= Group.new
  end

  def _test_valid
    assert group.valid?
  end

  def test_by_department
    group_1 = create(:group, chinese_name: 'test_1', english_name: 'test_1', simple_chinese_name: 'test_1')
    group_2 = create(:group, chinese_name: 'test_2', english_name: 'test_2', simple_chinese_name: 'test_2')
    department_1 = create(:department, chinese_name: 'test_3', english_name: 'test_3', simple_chinese_name: 'test3')
    department_1.groups <<  group_1
    assert_equal Group.count, 2
    assert_equal Group.by_department_id(department_1.id).count, 1
  end
end
