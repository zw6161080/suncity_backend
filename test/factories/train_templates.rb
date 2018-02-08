FactoryGirl.define do
  factory :train_template do
    chinese_name "string"
    english_name "string"
    simple_chinese_name "string"
    course_number "string"
    teaching_form "string"
    train_template_type_id 0
    training_credits "string"
    online_or_offline_training "online_training"
    limit_number 0
    course_total_time "string"
    course_total_count "string"
    trainer "string"
    language_of_training "string"
    place_of_training "string"
    contact_person_of_training "string"
    course_series "string"
    course_certificate "string"
    introduction_of_trainee "string"
    introduction_of_course "string"
    goal_of_learning "string"
    content_of_course "string"
    goal_of_course "string"
    assessment_method "by_attendance_rate"
    comprehensive_attendance_not_less_than "string"
    test_scores_not_less_than "string"
    exam_format "online"
    exam_template_id nil
    comprehensive_attendance_and_test_scores_not_less_than "string"
    test_scores_percentage "string"
    notice "string"
    comment "string"
    creator_id 0
  end
end
