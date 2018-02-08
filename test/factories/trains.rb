FactoryGirl.define do
  factory :train do
    train_template_id 1
    chinese_name "MyString"
    english_name "MyString"
    simple_chinese_name "MyString"
    train_cost '0'
    status 'not_published'
    train_number 1
    train_date_begin "2017-07-11 09:50:50"
    train_date_end "2017-07-11 09:50:50"
    registration_date_begin "2017-07-11 09:50:50"
    registration_date_end "2017-07-11 09:50:50"
    registration_method "by_employee_and_department"
    limit_number 20
    train_place "MyString"
  end
end
