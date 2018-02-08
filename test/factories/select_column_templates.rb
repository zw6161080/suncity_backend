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

FactoryGirl.define do
  factory :select_column_template do
    
  end
end
