# == Schema Information
#
# Table name: pass_entry_trials
#
#  id                       :integer          not null, primary key
#  region                   :string
#  user_id                  :integer
#  apply_date               :date
#  creator_id               :integer
#  employee_advantage       :text
#  employee_need_to_improve :text
#  employee_opinion         :text
#  result                   :boolean
#  trial_expiration_date    :date
#  dismissal                :boolean
#  last_working_date        :date
#  comment                  :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

FactoryGirl.define do
  factory :pass_entry_trial do
    
  end
end
