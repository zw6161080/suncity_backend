class ChangeColumnsToTrains < ActiveRecord::Migration[5.0]
  def change
    add_column :trains, :train_template_chinese_name, :string
    add_column :trains, :train_template_english_name, :string
    add_column :trains, :train_template_simple_chinese_name, :string
    #课程编号
    add_column :trains, :course_number, :string
    #授课形式
    add_column :trains, :teaching_form, :string
    #培训种类id
    add_column :trains, :train_template_type_id, :integer
    #培训学分
    add_column :trains, :training_credits, :decimal, precision: 15, scale: 2
    #线上/线下培训
    add_column :trains, :online_or_offline_training, :integer
    #培训模板人数上限
    add_column :trains, :train_template_limit_number, :integer
    #培训总时数
    add_column :trains, :course_total_time, :decimal, precision: 15, scale: 2
    #培训总花费
    add_column :trains, :course_total_count, :decimal, precision: 15, scale: 2
    #授课/机构/单位
    add_column :trains, :trainer, :string
    #授课语言
    add_column :trains, :language_of_training, :string
    #授课地点
    add_column :trains, :place_of_training, :string
    #培训联络人
    add_column :trains, :contact_person_of_training, :string
    #课程系列
    add_column :trains, :course_series, :string
    #课程证书
    add_column :trains, :course_certificate, :string
    #授课对象
    add_column :trains, :introduction_of_trainee, :string
    #课程简介
    add_column :trains, :introduction_of_course, :string
    #学习目标
    add_column :trains, :goal_of_learning, :string
    #课程内容
    add_column :trains, :content_of_course, :string
    #课程目的
    add_column :trains, :goal_of_course, :string
    #考核方式
    add_column :trains, :assessment_method, :integer
    #考试分数不低于
    add_column :trains, :test_scores_not_less_than, :decimal, precision: 15, scale: 2
    #考试形式
    add_column :trains, :exam_format, :integer
    #使用试卷模板id
    add_column :trains, :exam_template_id, :integer
    #出席率不低于
    add_column :trains, :comprehensive_attendance_not_less_than, :decimal, precision: 15, scale: 2
    #综合出席率与考试分数不低于
    add_column :trains, :comprehensive_attendance_and_test_scores_not_less_than, :decimal, precision: 15, scale: 2
    #考试分数占比
    add_column :trains, :test_scores_percentage, :decimal, precision: 15, scale: 2
    #培训模板注意事项
    add_column :trains, :train_template_notice, :string
    #培训模板备注
    add_column :trains, :train_template_comment, :string
  end
end
