FactoryGirl.define do
  factory :report_column do
    report nil
    key "MyString"
    chinese_name "MyString"
    english_name "MyString"
    simple_chinese_name "MyString"
    value_type "string"
    data_index "MyString"
    search_type "screen"
    sorter false
    options_type "predefined"
    options_predefined [1, 2, 3]
    source_model "MyString"
    source_model_user_association_attribute "user_id"
    user_source_model_association_attribute "department_id"
    join_attribute "nil"
    source_attribute "MyString"
  end
end
