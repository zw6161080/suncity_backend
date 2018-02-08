# == Schema Information
#
# Table name: card_profiles
#
#  id                         :integer          not null, primary key
#  photo_id                   :integer
#  empo_chinese_name          :string
#  empo_english_name          :string
#  empoid                     :string
#  entry_date                 :date
#  sex                        :string
#  nation                     :string
#  status                     :string
#  approved_job_name          :string
#  approved_job_id            :string
#  allocation_company         :string
#  allocation_valid_date      :date
#  approval_id                :string
#  report_salary_count        :integer
#  report_salary_unit         :string
#  labor_company              :string
#  date_to_submit_data        :date
#  certificate_type           :string
#  certificate_id             :string
#  date_to_submit_certificate :date
#  date_to_stamp              :date
#  date_to_submit_fingermold  :date
#  card_id                    :string
#  cancel_date                :date
#  original_user              :string
#  comment                    :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

require 'test_helper'

class CardProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
