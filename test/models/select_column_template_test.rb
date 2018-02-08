# == Schema Information
#
# Table name: select_column_templates
#
#  id                 :integer          not null, primary key
#  name               :string
#  select_column_keys :jsonb
#  default            :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  region             :string
#

require 'test_helper'

class SelectColumnTemplateTest < ActiveSupport::TestCase
  test 'get all selectable column' do
    sections = Profile.template(region: 'macau')

    selectable_columns = sections.inject([]) do |carry, section|
      if section.respond_to?('selectable_fields')
        carry.concat(section.selectable_fields)
      end
      carry
    end

    assert_equal selectable_columns.count - 40, SelectColumnTemplate.all_selectable_columns(region: 'macau').count
  end

  test 'create a template' do
    all_selectable_columns = SelectColumnTemplate.all_selectable_columns(region: 'macau')

    choosing_columns = all_selectable_columns.sample((1..all_selectable_columns.length).to_a.sample)
    choosing_column_keys = choosing_columns.map{|field| field.key}

    template = SelectColumnTemplate.new
    template.name = Faker::Name.name
    template.select_column_keys = choosing_column_keys
    template.region = 'macau'
    assert template.save
  end

  test 'render json with select columns' do
    column = create_select_column_template
    data = column.as_json(methods: :select_columns)
    assert data.key?('select_columns')
  end
end
