# == Schema Information
#
# Table name: empo_cards
#
#  id                    :integer          not null, primary key
#  approved_job_name     :string
#  approved_job_number   :string
#  approval_valid_date   :date
#  report_salary_count   :integer
#  report_salary_unit    :string
#  allocation_valid_date :date
#  approved_number       :integer
#  used_number           :integer
#  operator_name         :string
#  approved_job_id       :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_empo_cards_on_approved_job_id  (approved_job_id)
#
# Foreign Keys
#
#  fk_rails_859fedda50  (approved_job_id => approved_jobs.id)
#

class EmpoCard < ApplicationRecord
  belongs_to :approved_job
end
