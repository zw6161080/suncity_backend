# == Schema Information
#
# Table name: applicant_select_column_templates
#
#  id                 :integer          not null, primary key
#  name               :string
#  select_column_keys :jsonb
#  default            :boolean          default(FALSE)
#  region             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class ApplicantSelectColumnTemplateTest < ActiveSupport::TestCase
  test '可选字段列表' do
    columns =  ApplicantSelectColumnTemplate.all_selectable_columns(region: 'macau')
    assert columns
    sections = ApplicantProfile.template(region: 'macau')

    selectable_columns = sections.inject([]) do |carry, section|
      if section.respond_to?('selectable_fields')
        carry.concat(section.selectable_fields)
      end
      carry
    end

    assert_equal selectable_columns.count, columns.count
    assert columns.map{|c| c.attributes['chinese_name']}.include?('需澳門簽證？')
  end
end
