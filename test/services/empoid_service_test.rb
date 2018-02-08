require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  test '获取个人档案id测试' do
    assert_equal "10000001", EmpoidService.get
    user = create(:user, {
      empoid: EmpoidService.get
    })
    
    assert_equal "10000002", EmpoidService.get
  end
end
