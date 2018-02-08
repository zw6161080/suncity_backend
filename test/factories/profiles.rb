# == Schema Information
#
# Table name: profiles
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  region                      :string
#  data                        :jsonb
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  filled_attachment_types     :jsonb
#  attachment_missing_sms_sent :boolean          default(FALSE)
#  is_stashed                  :boolean          default(FALSE)
#  welfare_template_effected   :boolean          default(TRUE)
#  current_template_type       :integer
#  current_welfare_template_id :integer
#  date_of_employment          :string
#

FactoryGirl.define do
  factory :profile do
    user
  end
end
