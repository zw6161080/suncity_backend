# == Schema Information
#
# Table name: job_transfers
#
#  id                           :integer          not null, primary key
#  region                       :string
#  apply_date                   :date
#  user_id                      :integer
#  transfer_type                :integer
#  transfer_type_id             :integer
#  position_start_date          :date
#  position_end_date            :date
#  apply_result                 :boolean
#  trial_expiration_date        :date
#  salary_template_id           :integer
#  new_company_id               :integer
#  new_location_id              :integer
#  new_department_id            :integer
#  new_position_id              :integer
#  new_grade                    :integer
#  new_working_category_id      :integer
#  instructions                 :string
#  original_company_id          :integer
#  original_location_id         :integer
#  original_department_id       :integer
#  original_position_id         :integer
#  original_grade               :integer
#  original_working_category_id :integer
#  inputter_id                  :integer
#  input_date                   :date
#  comment                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

FactoryGirl.define do
  factory :job_transfer do
    id 1
    region 'macau'
    apply_date '2017/02/01'
    user_id 1
    transfer_type 'pass_entry_trial'
    position_start_date '2017/02/01'
    position_end_date '2017/02/01'
    apply_result true
    trial_expiration_date '2017/02/01'
    new_company_name 'suncity_gaming_promotion_company_limited'
    new_location_id 1
    new_department_id 1
    new_position_id 1
    new_grade 1
    new_employment_status 'formal_employees'
    instructions 'instructions'
    original_company_name 'suncity_gaming_promotion_company_limited'
    original_location_id 1
    original_department_id 1
    original_position_id 1
    original_grade 1
    original_employment_status 'formal_employees'
    inputter_id 1
    input_date '2017/02/01'
    salary_calculation 'do_not_adjust_the_salary'
  end
end
