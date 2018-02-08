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

FactoryGirl.define do
  factory :card_profile do
    photo_id 1
    empo_chinese_name "MyString"
    empo_english_name "MyString"
    empoid "0001"
    entry_date "2017-05-15"
    sex "male"
    nation "china"
    status "canceled"
    approved_job_name "MyString"
    approved_job_number "MyString"
    allocation_company "suncity_group_tourism_limited"
    allocation_valid_date "2017-05-15"
    approval_id "MyString"
    report_salary_count 0
    report_salary_unit "hkd"
    labor_company "zhu_hai_international_company"
    date_to_submit_data "2017-05-15"
    certificate_type "passport"
    certificate_id "MyString"
    date_to_submit_certificate "2017-05-15"
    date_to_stamp "2017-05-15"
    date_to_submit_fingermold "2017-05-15"
    card_id "MyString"
    cancel_date "2017-05-15"
    original_user "MyString"
    comment "MyText"
    new_or_renew "new"
    new_approval_valid_date "2011-01-01"
    certificate_valid_date "2012-01-02"
    date_to_get_card "2011-11-11"
    card_valid_date "2011-11-11"
  end
end
