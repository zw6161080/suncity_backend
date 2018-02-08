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
#  department_id      :integer
#  attachType         :string
#
# Indexes
#
#  index_select_column_templates_on_default        (default)
#  index_select_column_templates_on_department_id  (department_id)
#

class SelectColumnTemplate < ApplicationRecord
  include SelectColumnTemplateAble
  validates :attachType, inclusion: {in: %w(profiles profileDepartment)}
  belongs_to :department
  def self.load_predefined
    SelectColumnTemplate.find_or_create_by(default: true) do |template|
      template.name = '初始模板'
      template.select_column_keys = %w(chinese_name english_name id_number)
      template.region = 'macau'
    end
  end

end
