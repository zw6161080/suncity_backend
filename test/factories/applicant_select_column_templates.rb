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

FactoryGirl.define do
  factory :applicant_select_column_template do
    
  end
end
