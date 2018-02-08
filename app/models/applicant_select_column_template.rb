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
# Indexes
#
#  index_applicant_select_column_templates_on_default  (default)
#

class ApplicantSelectColumnTemplate < ApplicationRecord
  include SelectColumnTemplateAble

  def self.default_select_columns
    %w{english_name chinese_name}
  end

  def self.section_template(region:)
    ApplicantProfile.template(region: region)
  end
end
