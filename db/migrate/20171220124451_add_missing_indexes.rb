class AddMissingIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :absenteeisms, :creator_id
    add_index :absenteeisms, :user_id
    add_index :adjust_roster_records, :creator_id
    add_index :adjust_roster_records, :user_a_id
    add_index :adjust_roster_records, :user_a_roster_id
    add_index :adjust_roster_records, :user_b_id
    add_index :adjust_roster_records, :user_b_roster_id
    add_index :adjust_roster_reports, :user_id
    add_index :agreement_files, :creator_id
    add_index :air_ticket_reimbursements, :user_id
    add_index :annual_attend_reports, :user_id
    add_index :annual_award_report_items, :annual_award_report_id
    add_index :annual_award_report_items, :department_id
    add_index :annual_award_report_items, :position_id
    add_index :annual_award_report_items, :user_id
    add_index :applicant_attachments, :creator_id
    add_index :appraisal_attachments, :creator_id
    add_index :assessment_questionnaire_items, :assessment_questionnaire_id, :name => 'assessment_questionnaire_index'
    add_index :assistant_profile_to_annual_work_awards, :annual_work_award_id, :name => 'annual_work_award_index'
    add_index :assistant_profiles, :paid_sick_leave_award_id
    add_index :attachment_items, :creator_id
    add_index :attachment_types, [:id, :type]
    add_index :attend_annual_reports, :department_id
    add_index :attend_annual_reports, :user_id
    add_index :attend_approvals, :user_id
    add_index :attend_attachments, :creator_id
    add_index :attend_logs, :attend_id
    add_index :attend_logs, :logger_id
    add_index :attend_monthly_reports, :department_id
    add_index :attend_monthly_reports, :user_id
    add_index :attend_states, :attend_id
    add_index :attends, :roster_object_id
    add_index :attends, :user_id
    add_index :audiences, :applicant_position_id
    add_index :audiences, :creator_id
    add_index :audiences, :user_id
    add_index :award_records, :creator_id
    add_index :award_records, :user_id
    add_index :background_declarations, :user_id
    add_index :bank_auto_pay_report_items, :department_id
    add_index :bank_auto_pay_report_items, :position_id
    add_index :bank_auto_pay_report_items, :user_id
    add_index :card_profiles, :user_id
    add_index :card_records, :current_user_id
    add_index :career_records, :department_id
    add_index :career_records, :group_id
    add_index :career_records, :inputer_id
    add_index :career_records, :position_id
    add_index :career_records, :user_id
    add_index :choice_questions, :questionnaire_id
    add_index :choice_questions, :questionnaire_template_id
    add_index :class_people_preferences, :roster_preference_id
    add_index :class_settings, :department_id
    add_index :classes_between_general_holiday_preferences, :roster_preference_id, :name => 'roster_preference_index'
    add_index :compensate_reports, :department_id
    add_index :compensate_reports, :user_id
    add_index :contract_informations, :attachment_id
    add_index :contract_informations, :contract_information_type_id
    add_index :contract_informations, :creator_id
    add_index :contract_informations, :profile_id
    add_index :contracts, :applicant_position_id
    add_index :contribution_report_items, :department_id
    add_index :contribution_report_items, :position_id
    add_index :contribution_report_items, :user_id
    add_index :department_statuses, :department_id
    add_index :department_statuses, :float_salary_month_entry_id
    add_index :departments, :head_id
    add_index :departure_employee_taxpayer_numbering_report_items, :user_id, :name => 'departure_employee_taxpayer_on_user_id'
    add_index :dimission_appointments, :inputter_id
    add_index :dimission_appointments, :user_id
    add_index :dimission_follow_ups, :handler_id
    add_index :dimissions, :group_id
    add_index :education_informations, :creator_id
    add_index :education_informations, :profile_id
    add_index :employee_fund_switching_report_items, :user_id
    add_index :employee_general_holiday_preferences, :employee_preference_id, :name => 'general_holiday_employee_preference_index'
    add_index :employee_preferences, :roster_preference_id
    add_index :employee_preferences, :user_id
    add_index :employee_redemption_report_items, :user_id
    add_index :employee_roster_preferences, :employee_preference_id
    add_index :entry_appointments, :inputter_id
    add_index :entry_appointments, :user_id
    add_index :entry_lists, :creator_id
    add_index :entry_lists, :title_id
    add_index :entry_lists, :train_id
    add_index :entry_lists, :user_id
    add_index :family_declaration_items, :creator_id
    add_index :family_declaration_items, :profile_id
    add_index :family_member_informations, :user_id
    add_index :fill_in_the_blank_questions, :questionnaire_id
    add_index :fill_in_the_blank_questions, :questionnaire_template_id
    add_index :final_lists, :entry_list_id
    add_index :final_lists, :train_id
    add_index :final_lists, :user_id
    add_index :general_holiday_interval_preferences, :roster_preference_id, :name => 'interval_preferences_roster_preference_index'
    add_index :holiday_records, :creator_id
    add_index :holiday_records, :reserved_holiday_setting_id
    add_index :holiday_records, :user_id
    add_index :holiday_surplus_reports, :user_id
    add_index :holiday_switch_items, :user_b_id
    add_index :holiday_switch_items, :user_id
    add_index :holiday_switches, :creator_id
    add_index :immediate_leaves, :creator_id
    add_index :immediate_leaves, :user_id
    add_index :interviewers, :creator_id
    add_index :interviews, :applicant_position_id
    add_index :job_transfers, :inputter_id
    add_index :job_transfers, :new_department_id
    add_index :job_transfers, :new_location_id
    add_index :job_transfers, :new_position_id
    add_index :job_transfers, :original_department_id
    add_index :job_transfers, :original_location_id
    add_index :job_transfers, :original_position_id
    add_index :job_transfers, :user_id
    add_index :language_skills, :user_id
    add_index :lent_records, :user_id
    add_index :lent_temporarily_items, :lent_location_id
    add_index :lent_temporarily_items, :lent_temporarily_apply_id
    add_index :lent_temporarily_items, :user_id
    add_index :location_department_statuses, :department_id
    add_index :location_department_statuses, :float_salary_month_entry_id, :name => 'department_float_salary_month_entry_index'
    add_index :location_department_statuses, :location_id
    add_index :location_statuses, :float_salary_month_entry_id
    add_index :location_statuses, :location_id
    add_index :love_fund_records, :creator_id
    add_index :love_funds, :profile_id
    add_index :matrix_single_choice_items, :matrix_single_choice_question_id, :name => 'matrix_single_choice_question_index'
    add_index :matrix_single_choice_questions, :questionnaire_id
    add_index :matrix_single_choice_questions, :questionnaire_template_id, :name => 'xxx_questionnaire_template_index'
    add_index :medical_records, :creator_id
    add_index :month_salary_attachments, :attachment_id
    add_index :museum_records, :user_id
    add_index :my_attachments, :attachment_id
    add_index :my_attachments, :user_id
    add_index :occupation_tax_items, :department_id
    add_index :occupation_tax_items, :position_id
    add_index :online_materials, :attachment_id
    add_index :online_materials, :creator_id
    add_index :options, :choice_question_id
    add_index :over_times, :creator_id
    add_index :over_times, :user_id
    add_index :overtime_records, :creator_id
    add_index :overtime_records, :user_id
    add_index :paid_sick_leave_report_items, :paid_sick_leave_report_id
    add_index :paid_sick_leave_report_items, :user_id
    add_index :pass_entry_trials, :user_id
    add_index :pass_trials, :user_id
    add_index :pay_slips, :user_id
    add_index :profile_attachments, :attachment_id
    add_index :profile_attachments, :creator_id
    add_index :profile_attachments, :profile_attachment_type_id
    add_index :profile_attachments, :profile_id
    add_index :profit_conflict_informations, :user_id
    add_index :provident_fund_member_report_items, :user_id
    add_index :provident_funds, :first_beneficiary_id
    add_index :provident_funds, :profile_id
    add_index :provident_funds, :second_beneficiary_id
    add_index :provident_funds, :third_beneficiary_id
    add_index :provident_funds, :user_id
    add_index :punch_card_states, :creator_id
    add_index :punch_card_states, :user_id
    add_index :questionnaire_templates, :creator_id
    add_index :questionnaires, :questionnaire_template_id
    add_index :questionnaires, :release_user_id
    add_index :questionnaires, :user_id
    add_index :resignation_records, :user_id
    add_index :revise_clock_assistants, :revise_clock_item_id
    add_index :revise_clock_items, :user_id
    add_index :revise_clocks, :creator_id
    add_index :revise_clocks, :user_id
    add_index :roster_instructions, :user_id
    add_index :roster_interval_preferences, :roster_preference_id
    add_index :roster_lists, :department_id
    add_index :roster_lists, :location_id
    add_index :roster_model_states, :roster_model_id
    add_index :roster_model_states, :user_id
    add_index :roster_model_weeks, :roster_model_id
    add_index :roster_models, :department_id
    add_index :roster_object_logs, :approver_id
    add_index :roster_object_logs, :class_setting_id
    add_index :roster_object_logs, :roster_object_id
    add_index :roster_object_logs, :working_hours_transaction_record_id
    add_index :roster_objects, :class_setting_id
    add_index :roster_objects, :department_id
    add_index :roster_objects, :holiday_record_id
    add_index :roster_objects, :location_id
    add_index :roster_objects, :roster_list_id
    add_index :roster_objects, :user_id
    add_index :roster_objects, :working_hours_transaction_record_id
    add_index :roster_preferences, :department_id
    add_index :roster_preferences, :latest_updater_id
    add_index :roster_preferences, :location_id
    add_index :salary_records, :salary_template_id
    add_index :salary_records, :user_id
    add_index :salary_values, :resignation_record_id
    add_index :salary_values, :salary_column_id
    add_index :salary_values, :user_id
    add_index :select_column_templates, :department_id
    add_index :shift_statuses, :user_id
    add_index :sign_card_reasons, :sign_card_setting_id
    add_index :sign_card_records, :creator_id
    add_index :sign_card_records, :user_id
    add_index :sign_lists, :final_list_id
    add_index :sign_lists, :train_class_id
    add_index :sign_lists, :train_id
    add_index :sign_lists, :user_id
    add_index :social_security_fund_items, :department_id
    add_index :social_security_fund_items, :position_id
    add_index :special_assessments, :user_id
    add_index :student_evaluations, :lecturer_id
    add_index :student_evaluations, :train_id
    add_index :student_evaluations, :user_id
    add_index :supervisor_assessments, :user_id
    add_index :titles, :train_id
    add_index :train_classes, :title_id
    add_index :train_classes, :train_id
    add_index :train_records, :train_id
    add_index :train_templates, :creator_id
    add_index :train_templates, :exam_template_id
    add_index :train_templates, :train_template_type_id
    add_index :training_courses, :transfer_position_apply_by_employee_id, :name => 'transfer_position_apply_by_employee_index'
    add_index :training_courses, :user_id
    add_index :training_papers, :train_id
    add_index :training_papers, :user_id
    add_index :trains, :train_template_id
    add_index :transfer_location_items, :transfer_location_apply_id
    add_index :transfer_location_items, :transfer_location_id
    add_index :transfer_location_items, :user_id
    add_index :transfer_position_apply_by_departments, :apply_department_id, :name => 'tp_apply_department_index_111'
    add_index :transfer_position_apply_by_departments, :apply_group_id, :name => 'tp_apply_group_index'
    add_index :transfer_position_apply_by_departments, :apply_location_id, :name => 'tp_apply_location_index'
    add_index :transfer_position_apply_by_departments, :apply_position_id, :name => 'tp_apply_position_index'
    add_index :transfer_position_apply_by_departments, :transfer_department_id, :name => 'tp_transfer_department_index'
    add_index :transfer_position_apply_by_departments, :transfer_group_id, :name => 'tp_transfer_group_index'
    add_index :transfer_position_apply_by_departments, :transfer_location_id, :name => 'tp_transfer_location_index'
    add_index :transfer_position_apply_by_departments, :transfer_position_id, :name => 'tp_transfer_position_index'
    add_index :transfer_position_apply_by_departments, :user_id, :name => 'tp_user_index'
    add_index :transfer_position_apply_by_employees, :apply_department_id, :name => 'tp_a_by_emp_apply_department_index'
    add_index :transfer_position_apply_by_employees, :apply_group_id, :name => 'tp_a_by_emp_apply_group_index'
    add_index :transfer_position_apply_by_employees, :apply_location_id, :name => 'tp_a_by_emp_apply_location_index'
    add_index :transfer_position_apply_by_employees, :apply_position_id, :name => 'tp_a_by_emp_apply_position_index'
    add_index :transfer_position_apply_by_employees, :transfer_department_id, :name => 'tp_a_by_emp_transfer_department_index'
    add_index :transfer_position_apply_by_employees, :transfer_group_id, :name => 'tp_a_by_emp_transfer_group_index'
    add_index :transfer_position_apply_by_employees, :transfer_location_id, :name => 'tp_a_by_emp_transfer_location_index'
    add_index :transfer_position_apply_by_employees, :transfer_position_id, :name => 'tp_a_by_emp_transfer_position_index'
    add_index :transfer_position_apply_by_employees, :user_id, :name => 'tp_a_by_emp_user_index'
    add_index :typhoon_qualified_records, :typhoon_setting_id
    add_index :typhoon_qualified_records, :user_id
    add_index :users, :department_id
    add_index :users, :location_id
    add_index :users, :position_id
    add_index :welfare_records, :user_id
    add_index :welfare_records, :welfare_template_id
    add_index :whether_together_preferences, :roster_preference_id
    add_index :work_experences, :creator_id
    add_index :work_experences, :profile_id
    add_index :working_hours_transaction_records, :creator_id
    add_index :working_hours_transaction_records, :user_a_id
    add_index :working_hours_transaction_records, :user_b_id
  end
end
