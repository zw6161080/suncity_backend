# == Schema Information
#
# Table name: pass_entry_trials
#
#  id                       :integer          not null, primary key
#  region                   :string
#  user_id                  :integer
#  apply_date               :date
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
#  salary_record            :jsonb
#  new_salary_record        :jsonb
#  salary_calculation       :string
#
# Indexes
#
#  index_pass_entry_trials_on_user_id  (user_id)
#

class PassEntryTrial < ApplicationRecord
  include JobTransferAble
  belongs_to :user, required: true
  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy
  has_one :assessment_questionnaire, as: :questionnairable, dependent: :destroy
  has_many :job_transfers, as: :transferable



end
