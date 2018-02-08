require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  test '读取 config root 设置测试' do
    errors_config = YAML.load_file("#{Rails.root}/config/api_errors.yml")
    assert_equal errors_config, Config.get('api_errors')
  end

  test 'read config in config predefined root' do
    holiday_report = YAML.load_file("#{Rails.root}/config/predefined/holiday_report.yml")
    assert_equal holiday_report, Config.get('holiday_report')
  end
end
