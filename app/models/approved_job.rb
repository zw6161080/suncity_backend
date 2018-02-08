# == Schema Information
#
# Table name: approved_jobs
#
#  id                  :integer          not null, primary key
#  approved_job_name   :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  number              :integer
#  report_salary_count :integer
#  report_salary_unit  :string
#

class ApprovedJob < ApplicationRecord
  has_many :empo_cards
end
