require 'test_helper'

class ProfileSectionTest < ActiveSupport::TestCase

  test '获取所有Section测试' do
    raw_config = ProfileSection.raw_config
    profile_sections = ProfileSection.all(region: 'macau')

    assert_equal raw_config.length, profile_sections.length

    personal_information_key = 'personal_information'

    # get personal information section
    personal_information = profile_sections.find do |profile_section|
      profile_section.key == personal_information_key
    end

    assert_equal personal_information.key, ProfileSection.find(personal_information_key).key
  end

  test 'as json test' do
    personal_information = ProfileSection.find('personal_information', region: 'macau')
    assert personal_information.as_json   
  end

  test '填充value测试' do
    section = ProfileSection.find('personal_information', region: 'macau')

    fields = random_fill_fields(section.fields.as_json).map{ |field|
      {
        'key' => field['key'],
        'value' => field['value'],
      }
    }.inject({}){|hash, field| hash[field['key']] = field['value']; hash}

    section.merge_params({
      'field_values' => fields
    })

    filled_value_section = section.as_json

    filled_value_section['fields'].each do |field|
      assert field.key?('value')
    end

    #to value data test
    data = section.to_value_data
    assert data.key?('key')
    assert data.key?('field_values')

    section = ProfileSection.find('salary_information', region: 'macau')
    fields = random_fill_fields(section.fields.as_json).map{ |field|
      {
          'key' => field['key'],
          'value' => field['value'],
      }
    }.inject({}){|hash, field| hash[field['key']] = field['value']; hash}
    section.merge_params({
                             'field_values' => fields
                         })

    filled_value_section = section.as_json

    filled_value_section['fields'].each do |field|
      assert field.key?('value')
    end

    #to value data test
    data = section.to_value_data
    assert data.key?('key')
    assert data.key?('field_values')
  end
end
