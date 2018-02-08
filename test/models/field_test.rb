require 'test_helper'

class ProfileSectionTest < ActiveSupport::TestCase

  test 'build field' do
    chinese_name_field = Field.find('chinese_name')
    assert_equal 'chinese_name', chinese_name_field.key
  end

  test 'select field test' do
    gender = Field.find('gender')
    assert gender.select
  end

  test 'fill field value' do
    field = Field.all.first
    field.value = 'Hello'
    assert_equal 'Hello', field.as_json['value']
  end

  test 'field merge attribute test' do
    field = Field.find('suncity_charity_fund_status')
    assert field.select
    assert field.select.default
  end

  test 'field default value' do
    field = Field.find('suncity_charity_join_date')
    field_json = field.as_json
    assert field_json.key?('default')
  end

  test 'field render to readable string' do
    field = Field.find('gender')
    field.value = 'male'

    assert_equal '男', field.render_value('chinese')
    assert_equal 'male', field.render_value('english')
  end

  test 'field render string with api select' do
    position = create(:position)
    field = Field.find('position')
    field.value = position.id
    assert_equal position.chinese_name, field.render_value('chinese')
    assert_equal position.english_name, field.render_value('english')

    field.value = 'not exist'
    assert_equal 'not exist', field.render_value('chinese')
  end
end
