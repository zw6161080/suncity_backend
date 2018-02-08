# == Schema Information
#
# Table name: approved_jobs
#
#  id                :integer          not null, primary key
#  approved_job_name :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  number            :integer
#

FactoryGirl.define do
  factory :approved_job do
    approved_job_name "总经理"
    number 0
    report_salary_count 10000
    report_salary_unit 'HKD'
  end
end
