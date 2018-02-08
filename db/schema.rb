# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180202123535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "absenteeism_items", force: :cascade do |t|
    t.integer  "absenteeism_id"
    t.text     "comment"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.date     "date"
    t.string   "shift_info"
    t.string   "work_time"
    t.string   "come"
    t.string   "leave"
    t.index ["absenteeism_id"], name: "index_absenteeism_items_on_absenteeism_id", using: :btree
  end

  create_table "absenteeisms", force: :cascade do |t|
    t.date     "date"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "status",      default: 1,             null: false
    t.integer  "item_count"
    t.text     "comment"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "record_type", default: "absenteeism", null: false
    t.index ["creator_id"], name: "index_absenteeisms_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_absenteeisms_on_user_id", using: :btree
  end

  create_table "accounting_statement_month_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "settle_year_month"
    t.datetime "salary_begin_date"
    t.datetime "salary_end_date"
    t.string   "check_or_cash"
    t.boolean  "is_dismissed_this_month"
    t.decimal  "actual_amount_mop",                          precision: 15, scale: 2
    t.decimal  "actual_amount_hkd",                          precision: 15, scale: 2
    t.decimal  "social_security_fund_reduction_mop",         precision: 15, scale: 2
    t.decimal  "occupation_tax_reduction_mop",               precision: 15, scale: 2
    t.integer  "remaining_annual_holidays"
    t.integer  "paid_sick_leave_days"
    t.decimal  "total_amount_mop",                           precision: 15, scale: 2
    t.decimal  "base_salary_mop",                            precision: 15, scale: 2
    t.decimal  "overtime_pay_mop",                           precision: 15, scale: 2
    t.decimal  "compulsion_holiday_compensation_mop",        precision: 15, scale: 2
    t.decimal  "public_holiday_compensation_mop",            precision: 15, scale: 2
    t.decimal  "medicare_reimbursement_mop",                 precision: 15, scale: 2
    t.decimal  "vip_card_consumption_mop",                   precision: 15, scale: 2
    t.decimal  "paid_maternity_compensation_mop",            precision: 15, scale: 2
    t.decimal  "double_pay_mop",                             precision: 15, scale: 2
    t.decimal  "year_end_bonus_mop",                         precision: 15, scale: 2
    t.decimal  "seniority_compensation_mop",                 precision: 15, scale: 2
    t.decimal  "dismission_annual_holiday_compensation_mop", precision: 15, scale: 2
    t.decimal  "dismission_inform_period_compensation_mop",  precision: 15, scale: 2
    t.decimal  "total_reduction_mop",                        precision: 15, scale: 2
    t.decimal  "medical_insurance_plan_reduction_mop",       precision: 15, scale: 2
    t.decimal  "public_accumulation_fund_reduction_mop",     precision: 15, scale: 2
    t.decimal  "love_fund_reduction_mop",                    precision: 15, scale: 2
    t.decimal  "absenteeism_reduction_mop",                  precision: 15, scale: 2
    t.decimal  "immediate_leave_reduction_mop",              precision: 15, scale: 2
    t.decimal  "unpaid_leave_reduction_mop",                 precision: 15, scale: 2
    t.decimal  "unpaid_marriage_leave_reduction_mop",        precision: 15, scale: 2
    t.decimal  "unpaid_compassionate_leave_reduction_mop",   precision: 15, scale: 2
    t.decimal  "unpaid_maternity_leave_reduction_mop",       precision: 15, scale: 2
    t.decimal  "pregnant_sick_leave_reduction_mop",          precision: 15, scale: 2
    t.decimal  "occupational_injury_reduction_mop",          precision: 15, scale: 2
    t.decimal  "total_salary_hkd",                           precision: 15, scale: 2
    t.decimal  "benefits_hkd",                               precision: 15, scale: 2
    t.decimal  "incentive_hkd",                              precision: 15, scale: 2
    t.decimal  "housing_benefit_hkd",                        precision: 15, scale: 2
    t.decimal  "cover_charge_hkd",                           precision: 15, scale: 2
    t.decimal  "kill_bonus_hkd",                             precision: 15, scale: 2
    t.decimal  "performance_bonus_hkd",                      precision: 15, scale: 2
    t.decimal  "swiping_card_bonus_hkd",                     precision: 15, scale: 2
    t.decimal  "commission_margin_hkd",                      precision: 15, scale: 2
    t.decimal  "collect_accounts_bonus_hkd",                 precision: 15, scale: 2
    t.decimal  "exchange_rate_bonus_hkd",                    precision: 15, scale: 2
    t.decimal  "zunhuadian_hkd",                             precision: 15, scale: 2
    t.decimal  "xinchunlishi_hkd",                           precision: 15, scale: 2
    t.decimal  "project_bonus_hkd",                          precision: 15, scale: 2
    t.decimal  "shangpin_bonus_hkd",                         precision: 15, scale: 2
    t.decimal  "dispatch_bonus_hkd",                         precision: 15, scale: 2
    t.decimal  "recommand_new_guest_bonus_hkd",              precision: 15, scale: 2
    t.decimal  "typhoon_benefits_hkd",                       precision: 15, scale: 2
    t.decimal  "annual_incentive_payment_hkd",               precision: 15, scale: 2
    t.decimal  "back_pay_hkd",                               precision: 15, scale: 2
    t.decimal  "total_reduction_hkd",                        precision: 15, scale: 2
    t.decimal  "absenteeism_reduction_hkd",                  precision: 15, scale: 2
    t.decimal  "immediate_leave_reduction_hkd",              precision: 15, scale: 2
    t.decimal  "unpaid_leave_reduction_hkd",                 precision: 15, scale: 2
    t.decimal  "unpaid_marriage_leave_reduction_hkd",        precision: 15, scale: 2
    t.decimal  "unpaid_compassionate_leave_reduction_hkd",   precision: 15, scale: 2
    t.decimal  "unpaid_maternity_leave_reduction_hkd",       precision: 15, scale: 2
    t.decimal  "pregnant_sick_leave_reduction_hkd",          precision: 15, scale: 2
    t.decimal  "occupational_injury_reduction_hkd",          precision: 15, scale: 2
    t.decimal  "paid_sick_leave_reduction_hkd",              precision: 15, scale: 2
    t.decimal  "late_reduction_hkd",                         precision: 15, scale: 2
    t.decimal  "missing_punch_card_reduction_hkd",           precision: 15, scale: 2
    t.decimal  "punishment_reduction_hkd",                   precision: 15, scale: 2
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "accounting_statement_month_report_id"
    t.index ["accounting_statement_month_report_id"], name: "index_accounting_statement_item_on_report_id", using: :btree
    t.index ["user_id"], name: "index_accounting_statement_month_items_on_user_id", using: :btree
  end

  create_table "adjust_roster_records", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_a_id"
    t.integer  "user_b_id"
    t.date     "user_a_adjust_date"
    t.integer  "user_a_roster_id"
    t.date     "user_b_adjust_date"
    t.integer  "user_b_roster_id"
    t.integer  "apply_type"
    t.boolean  "is_director_special_approval"
    t.boolean  "is_deleted"
    t.text     "comment"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "creator_id"
    t.string   "special_approver"
    t.index ["creator_id"], name: "index_adjust_roster_records_on_creator_id", using: :btree
    t.index ["user_a_id"], name: "index_adjust_roster_records_on_user_a_id", using: :btree
    t.index ["user_a_roster_id"], name: "index_adjust_roster_records_on_user_a_roster_id", using: :btree
    t.index ["user_b_id"], name: "index_adjust_roster_records_on_user_b_id", using: :btree
    t.index ["user_b_roster_id"], name: "index_adjust_roster_records_on_user_b_roster_id", using: :btree
  end

  create_table "adjust_roster_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "not_special"
    t.integer  "not_special_for_class"
    t.integer  "not_special_for_holiday"
    t.integer  "special"
    t.integer  "special_for_class"
    t.integer  "special_for_holiday"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["user_id"], name: "index_adjust_roster_reports_on_user_id", using: :btree
  end

  create_table "agreement_files", force: :cascade do |t|
    t.integer  "agreement_id"
    t.integer  "applicant_position_id"
    t.integer  "attachment_id"
    t.integer  "creator_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "file_key"
    t.index ["agreement_id"], name: "index_agreement_files_on_agreement_id", using: :btree
    t.index ["applicant_position_id"], name: "index_agreement_files_on_applicant_position_id", using: :btree
    t.index ["attachment_id"], name: "index_agreement_files_on_attachment_id", using: :btree
    t.index ["creator_id"], name: "index_agreement_files_on_creator_id", using: :btree
  end

  create_table "agreements", force: :cascade do |t|
    t.string   "title"
    t.integer  "attachment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "region"
    t.index ["attachment_id"], name: "index_agreements_on_attachment_id", using: :btree
  end

  create_table "air_ticket_reimbursements", force: :cascade do |t|
    t.date     "date_of_employment"
    t.string   "route"
    t.date     "apply_date"
    t.date     "reimbursement_date"
    t.string   "remarks"
    t.integer  "user_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.decimal  "ticket_price",       precision: 10, scale: 2
    t.decimal  "exchange_rate",      precision: 10, scale: 2
    t.decimal  "ticket_price_macau", precision: 10, scale: 2
    t.index ["user_id"], name: "index_air_ticket_reimbursements_on_user_id", using: :btree
  end

  create_table "annual_attend_reports", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "user_id"
    t.integer  "year"
    t.boolean  "is_meet"
    t.date     "settlement_date"
    t.decimal  "money_hkd",       precision: 15, scale: 2
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["user_id"], name: "index_annual_attend_reports_on_user_id", using: :btree
  end

  create_table "annual_award_report_items", force: :cascade do |t|
    t.integer  "annual_award_report_id"
    t.integer  "user_id"
    t.boolean  "add_double_pay"
    t.decimal  "double_pay_hkd",                  precision: 15, scale: 2
    t.decimal  "double_pay_alter_hkd",            precision: 15, scale: 2
    t.decimal  "double_pay_final_hkd",            precision: 15, scale: 2
    t.boolean  "add_end_bonus"
    t.decimal  "end_bonus_hkd",                   precision: 15, scale: 2
    t.integer  "praise_times"
    t.decimal  "end_bonus_add_hkd",               precision: 15, scale: 2
    t.integer  "absence_times"
    t.integer  "notice_times"
    t.integer  "late_times"
    t.integer  "lack_sign_card_times"
    t.integer  "punishment_times"
    t.decimal  "de_end_bonus_for_absence_hkd",    precision: 15, scale: 2
    t.decimal  "de_bonus_for_notice_hkd",         precision: 15, scale: 2
    t.decimal  "de_end_bonus_for_late_hkd",       precision: 15, scale: 2
    t.decimal  "de_end_bonus_for_sign_card_hkd",  precision: 15, scale: 2
    t.decimal  "de_end_bonus_for_punishment_hkd", precision: 15, scale: 2
    t.decimal  "de_bonus_total_hkd",              precision: 15, scale: 2
    t.decimal  "end_bonus_final_hkd",             precision: 15, scale: 2
    t.boolean  "present_at_duty_first_half"
    t.decimal  "annual_at_duty_basic_hkd",        precision: 15, scale: 2
    t.decimal  "annual_at_duty_final_hkd",        precision: 15, scale: 2
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "department_id"
    t.integer  "position_id"
    t.datetime "date_of_employment"
    t.decimal  "work_days_this_year",             precision: 15, scale: 2
    t.decimal  "deducted_days",                   precision: 15, scale: 2
    t.index ["annual_award_report_id"], name: "index_annual_award_report_items_on_annual_award_report_id", using: :btree
    t.index ["department_id"], name: "index_annual_award_report_items_on_department_id", using: :btree
    t.index ["position_id"], name: "index_annual_award_report_items_on_position_id", using: :btree
    t.index ["user_id"], name: "index_annual_award_report_items_on_user_id", using: :btree
  end

  create_table "annual_award_reports", force: :cascade do |t|
    t.datetime "year_month"
    t.decimal  "annual_attendance_award_hkd",      precision: 15, scale: 2
    t.string   "annual_bonus_grant_type"
    t.jsonb    "grant_type_rule"
    t.decimal  "absence_deducting",                precision: 15, scale: 2
    t.decimal  "notice_deducting",                 precision: 15, scale: 2
    t.decimal  "late_5_times_deducting",           precision: 15, scale: 2
    t.decimal  "sign_card_deducting",              precision: 15, scale: 2
    t.decimal  "one_letter_of_warning_deducting",  precision: 15, scale: 2
    t.decimal  "two_letters_of_warning_deducting", precision: 15, scale: 2
    t.decimal  "each_piece_of_awarding_deducting", precision: 15, scale: 2
    t.string   "method_of_settling_accounts"
    t.datetime "award_date"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "status"
  end

  create_table "annual_bonus_events", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.datetime "begin_date"
    t.datetime "end_date"
    t.decimal  "annual_incentive_payment_hkd", precision: 15, scale: 2
    t.string   "year_end_bonus_rule"
    t.decimal  "year_end_bonus_mop",           precision: 15, scale: 2
    t.string   "settlement_type"
    t.datetime "settlement_salary_year_month"
    t.datetime "settlement_date"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "grant_status"
  end

  create_table "annual_bonus_items", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "has_annual_incentive_payment"
    t.decimal  "annual_incentive_payment_hkd", precision: 15, scale: 2
    t.boolean  "has_double_pay"
    t.decimal  "double_pay_mop",               precision: 15, scale: 2
    t.boolean  "has_year_end_bonus"
    t.decimal  "year_end_bonus_mop",           precision: 15, scale: 2
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "annual_bonus_event_id"
    t.datetime "career_entry_date"
    t.index ["annual_bonus_event_id"], name: "index_annual_bonus_items_on_annual_bonus_event_id", using: :btree
    t.index ["user_id"], name: "index_annual_bonus_items_on_user_id", using: :btree
  end

  create_table "annual_work_awards", force: :cascade do |t|
    t.string   "award_chinese_name",             null: false
    t.string   "award_english_name",             null: false
    t.string   "begin_date",                     null: false
    t.string   "end_date",                       null: false
    t.integer  "num_of_award",                   null: false
    t.integer  "has_paid",           default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "applicant_attachments", force: :cascade do |t|
    t.integer  "applicant_profile_id"
    t.integer  "applicant_attachment_type_id"
    t.integer  "attachment_id"
    t.string   "file_name"
    t.text     "description"
    t.integer  "creator_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["applicant_attachment_type_id"], name: "index_applicant_attachments_on_applicant_attachment_type_id", using: :btree
    t.index ["applicant_profile_id"], name: "index_applicant_attachments_on_applicant_profile_id", using: :btree
    t.index ["attachment_id"], name: "index_applicant_attachments_on_attachment_id", using: :btree
    t.index ["creator_id"], name: "index_applicant_attachments_on_creator_id", using: :btree
  end

  create_table "applicant_positions", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "position_id"
    t.integer  "applicant_profile_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "order"
    t.integer  "status",               default: 0
    t.text     "comment"
    t.index ["applicant_profile_id"], name: "index_applicant_positions_on_applicant_profile_id", using: :btree
    t.index ["department_id"], name: "index_applicant_positions_on_department_id", using: :btree
    t.index ["order"], name: "index_applicant_positions_on_order", using: :btree
    t.index ["position_id"], name: "index_applicant_positions_on_position_id", using: :btree
  end

  create_table "applicant_profiles", force: :cascade do |t|
    t.string   "applicant_no"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "id_card_number"
    t.string   "region"
    t.jsonb    "data"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "source"
    t.integer  "profile_id"
    t.jsonb    "get_info_from"
    t.string   "empoid_for_create_profile"
    t.index ["applicant_no"], name: "index_applicant_profiles_on_applicant_no", using: :btree
    t.index ["chinese_name"], name: "index_applicant_profiles_on_chinese_name", using: :btree
    t.index ["english_name"], name: "index_applicant_profiles_on_english_name", using: :btree
    t.index ["id_card_number"], name: "index_applicant_profiles_on_id_card_number", using: :btree
    t.index ["profile_id"], name: "index_applicant_profiles_on_profile_id", using: :btree
    t.index ["region"], name: "index_applicant_profiles_on_region", using: :btree
    t.index ["source"], name: "index_applicant_profiles_on_source", using: :btree
  end

  create_table "applicant_select_column_templates", force: :cascade do |t|
    t.string   "name"
    t.jsonb    "select_column_keys"
    t.boolean  "default",            default: false
    t.string   "region"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["default"], name: "index_applicant_select_column_templates_on_default", using: :btree
  end

  create_table "application_logs", force: :cascade do |t|
    t.integer  "applicant_position_id"
    t.integer  "user_id"
    t.string   "behavior"
    t.jsonb    "info"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["applicant_position_id"], name: "index_application_logs_on_applicant_position_id", using: :btree
    t.index ["user_id"], name: "index_application_logs_on_user_id", using: :btree
  end

  create_table "appraisal_attachments", force: :cascade do |t|
    t.integer  "attachment_id"
    t.integer  "creator_id"
    t.string   "file_type"
    t.string   "file_name"
    t.text     "comment"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "appraisal_attachable_type"
    t.integer  "appraisal_attachable_id"
    t.index ["appraisal_attachable_type", "appraisal_attachable_id"], name: "index_appraisal_attachments_on_appraisal_attachable_id", using: :btree
    t.index ["attachment_id"], name: "index_appraisal_attachments_on_attachment_id", using: :btree
    t.index ["creator_id"], name: "index_appraisal_attachments_on_creator_id", using: :btree
  end

  create_table "appraisal_basic_settings", force: :cascade do |t|
    t.integer  "ratio_superior"
    t.integer  "ratio_subordinate"
    t.integer  "ratio_collegue"
    t.integer  "ratio_self"
    t.integer  "ratio_others_superior"
    t.integer  "ratio_others_subordinate"
    t.integer  "ratio_others_collegue"
    t.boolean  "questionnaire_submit_once_only"
    t.string   "introduction"
    t.jsonb    "group_A"
    t.jsonb    "group_B"
    t.jsonb    "group_C"
    t.jsonb    "group_D"
    t.jsonb    "group_E"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "appraisal_department_settings", force: :cascade do |t|
    t.integer  "location_id"
    t.integer  "department_id"
    t.integer  "appraisal_basic_setting_id"
    t.boolean  "can_across_appraisal_grade"
    t.string   "appraisal_mode_superior"
    t.integer  "appraisal_times_superior"
    t.string   "appraisal_mode_collegue"
    t.integer  "appraisal_times_collegue"
    t.string   "appraisal_mode_subordinate"
    t.integer  "appraisal_times_subordinate"
    t.integer  "appraisal_grade_quantity_inside"
    t.boolean  "whether_group_inside"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "group_A_appraisal_template_id"
    t.integer  "group_B_appraisal_template_id"
    t.integer  "group_C_appraisal_template_id"
    t.integer  "group_D_appraisal_template_id"
    t.integer  "group_E_appraisal_template_id"
    t.index ["appraisal_basic_setting_id"], name: "idnex_appraisal_department_setting_on_basic", using: :btree
    t.index ["department_id"], name: "index_appraisal_department_settings_on_department_id", using: :btree
    t.index ["group_A_appraisal_template_id"], name: "index_appraisal_department_setting_on_group_A", using: :btree
    t.index ["group_B_appraisal_template_id"], name: "index_appraisal_department_setting_on_group_B", using: :btree
    t.index ["group_C_appraisal_template_id"], name: "index_appraisal_department_setting_on_group_C", using: :btree
    t.index ["group_D_appraisal_template_id"], name: "index_appraisal_department_setting_on_group_D", using: :btree
    t.index ["group_E_appraisal_template_id"], name: "index_appraisal_department_setting_on_group_E", using: :btree
    t.index ["location_id"], name: "index_appraisal_department_settings_on_location_id", using: :btree
  end

  create_table "appraisal_employee_settings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "appraisal_group_id"
    t.integer  "appraisal_department_setting_id"
    t.integer  "level_in_department"
    t.boolean  "has_finished"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["appraisal_department_setting_id"], name: "employee_on_department_setting", using: :btree
    t.index ["appraisal_group_id"], name: "index_appraisal_employee_settings_on_appraisal_group_id", using: :btree
    t.index ["user_id"], name: "index_appraisal_employee_settings_on_user_id", using: :btree
  end

  create_table "appraisal_for_departments", force: :cascade do |t|
    t.integer  "appraisal_id"
    t.integer  "department_id"
    t.integer  "participator_amount_in_department"
    t.decimal  "ave_total_appraisal_in_department", precision: 5, scale: 2
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.index ["appraisal_id"], name: "index_appraisal_for_departments_on_appraisal_id", using: :btree
    t.index ["department_id"], name: "index_appraisal_for_departments_on_department_id", using: :btree
  end

  create_table "appraisal_for_users", force: :cascade do |t|
    t.integer  "appraisal_id"
    t.integer  "appraisal_for_department_id"
    t.integer  "user_id"
    t.decimal  "ave_total_appraisal_self",    precision: 5, scale: 2
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.index ["appraisal_for_department_id"], name: "index_appraisal_for_users_on_appraisal_for_department_id", using: :btree
    t.index ["appraisal_id"], name: "index_appraisal_for_users_on_appraisal_id", using: :btree
    t.index ["user_id"], name: "index_appraisal_for_users_on_user_id", using: :btree
  end

  create_table "appraisal_groups", force: :cascade do |t|
    t.integer  "appraisal_department_setting_id"
    t.string   "name"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["appraisal_department_setting_id"], name: "index_appraisal_groups_on_appraisal_department_setting_id", using: :btree
  end

  create_table "appraisal_overall_scores", force: :cascade do |t|
    t.integer  "appraisal_id"
    t.decimal  "group_A_score", precision: 5, scale: 2
    t.decimal  "group_B_score", precision: 5, scale: 2
    t.decimal  "group_C_score", precision: 5, scale: 2
    t.decimal  "group_D_score", precision: 5, scale: 2
    t.decimal  "group_E_score", precision: 5, scale: 2
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["appraisal_id"], name: "index_appraisal_overall_scores_on_appraisal_id", using: :btree
  end

  create_table "appraisal_participate_departments", force: :cascade do |t|
    t.integer  "appraisal_id"
    t.integer  "location_id"
    t.integer  "department_id"
    t.boolean  "confirmed"
    t.integer  "participator_amount"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["appraisal_id"], name: "index_appraisal_participate_departments_on_appraisal_id", using: :btree
    t.index ["department_id"], name: "index_appraisal_participate_departments_on_department_id", using: :btree
    t.index ["location_id"], name: "index_appraisal_participate_departments_on_location_id", using: :btree
  end

  create_table "appraisal_participators", force: :cascade do |t|
    t.integer  "appraisal_id"
    t.integer  "user_id"
    t.integer  "department_id"
    t.integer  "appraisal_grade"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "location_id"
    t.integer  "appraisal_department_setting_id"
    t.integer  "appraisal_employee_setting_id"
    t.string   "appraisal_group"
    t.integer  "appraisal_questionnaire_template_id"
    t.string   "departmental_appraisal_group"
    t.index ["appraisal_department_setting_id"], name: "index_on_appraisal_participator_on_department_setting", using: :btree
    t.index ["appraisal_employee_setting_id"], name: "index_appraisal_participators_on_appraisal_employee_setting_id", using: :btree
    t.index ["appraisal_id"], name: "index_appraisal_participators_on_appraisal_id", using: :btree
    t.index ["department_id"], name: "index_appraisal_participators_on_department_id", using: :btree
    t.index ["location_id"], name: "index_appraisal_participators_on_location_id", using: :btree
    t.index ["user_id"], name: "index_appraisal_participators_on_user_id", using: :btree
  end

  create_table "appraisal_questionnaires", force: :cascade do |t|
    t.integer  "appraisal_id"
    t.integer  "appraisal_participator_id"
    t.integer  "questionnaire_id"
    t.datetime "submit_date"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "assess_type"
    t.decimal  "final_score",               precision: 5, scale: 2
    t.integer  "assessor_id"
    t.index ["appraisal_id"], name: "index_appraisal_questionnaires_on_appraisal_id", using: :btree
    t.index ["appraisal_participator_id"], name: "index_appraisal_questionnaires_on_appraisal_participator_id", using: :btree
    t.index ["assessor_id"], name: "index_appraisal_questionnaires_on_assessor_id", using: :btree
    t.index ["questionnaire_id"], name: "index_appraisal_questionnaires_on_questionnaire_id", using: :btree
  end

  create_table "appraisal_reports", force: :cascade do |t|
    t.integer  "appraisal_id"
    t.integer  "appraisal_participator_id"
    t.decimal  "overall_score",             precision: 5, scale: 2
    t.decimal  "superior_score",            precision: 5, scale: 2
    t.decimal  "colleague_score",           precision: 5, scale: 2
    t.decimal  "subordinate_score",         precision: 5, scale: 2
    t.decimal  "self_score",                precision: 5, scale: 2
    t.jsonb    "report_detail",                                     default: "{}", null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.string   "appraisal_group"
    t.index ["appraisal_id"], name: "index_appraisal_reports_on_appraisal_id", using: :btree
    t.index ["appraisal_participator_id"], name: "index_appraisal_reports_on_appraisal_participator_id", using: :btree
  end

  create_table "appraisals", force: :cascade do |t|
    t.string   "appraisal_status"
    t.string   "appraisal_name"
    t.datetime "date_begin"
    t.datetime "date_end"
    t.integer  "participator_amount"
    t.decimal  "ave_total_appraisal",            precision: 5, scale: 2
    t.decimal  "ave_superior_appraisal",         precision: 5, scale: 2
    t.decimal  "ave_colleague_appraisal",        precision: 5, scale: 2
    t.decimal  "ave_subordinate_appraisal",      precision: 5, scale: 2
    t.decimal  "ave_self_appraisal",             precision: 5, scale: 2
    t.string   "appraisal_introduction"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.jsonb    "group_situation"
    t.boolean  "complete_questionnaire"
    t.integer  "participator_department_amount"
    t.decimal  "ave_department_appraisal",       precision: 5, scale: 2
    t.decimal  "total_ave_self_appraisal",       precision: 5, scale: 2
    t.boolean  "release_reports"
    t.boolean  "release_interviews"
  end

  create_table "approval_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "datetime"
    t.text     "comment"
    t.string   "approvable_type"
    t.integer  "approvable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["approvable_type", "approvable_id"], name: "index_approval_items_on_approvable_type_and_approvable_id", using: :btree
    t.index ["user_id"], name: "index_approval_items_on_user_id", using: :btree
  end

  create_table "approved_jobs", force: :cascade do |t|
    t.string   "approved_job_name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "number"
    t.integer  "report_salary_count"
    t.string   "report_salary_unit"
  end

  create_table "assess_relationships", force: :cascade do |t|
    t.string   "assess_type"
    t.integer  "appraisal_id"
    t.integer  "appraisal_participator_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "assessor_id"
    t.index ["appraisal_id"], name: "index_assess_relationships_on_appraisal_id", using: :btree
    t.index ["appraisal_participator_id"], name: "index_assess_relationships_on_appraisal_participator_id", using: :btree
    t.index ["assessor_id"], name: "index_assess_relationships_on_assessor_id", using: :btree
  end

  create_table "assessment_questionnaire_items", force: :cascade do |t|
    t.string   "region"
    t.integer  "assessment_questionnaire_id"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "group_chinese_name"
    t.string   "group_english_name"
    t.string   "group_simple_chinese_name"
    t.integer  "order_no"
    t.integer  "score"
    t.string   "explain"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["assessment_questionnaire_id"], name: "assessment_questionnaire_index", using: :btree
  end

  create_table "assessment_questionnaires", force: :cascade do |t|
    t.string   "region"
    t.string   "questionnairable_type"
    t.integer  "questionnairable_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["questionnairable_type", "questionnairable_id"], name: "index_assess_ques_on_quesable_type_and_quesable_id", using: :btree
  end

  create_table "assistant_profile_to_annual_work_awards", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "annual_work_award_id"
    t.string   "date_of_employment"
    t.integer  "up_to_standard"
    t.integer  "money_of_award"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["annual_work_award_id"], name: "annual_work_award_index", using: :btree
  end

  create_table "assistant_profiles", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "paid_sick_leave_award_id"
    t.string   "date_of_employment"
    t.integer  "days_in_office"
    t.integer  "has_used_days"
    t.integer  "days_of_award"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["paid_sick_leave_award_id"], name: "index_assistant_profiles_on_paid_sick_leave_award_id", using: :btree
  end

  create_table "attachment_items", force: :cascade do |t|
    t.string   "file_name"
    t.integer  "creator_id"
    t.text     "comment"
    t.integer  "attachment_id"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["attachable_type", "attachable_id"], name: "index_attachment_items_on_attachable_type_and_attachable_id", using: :btree
    t.index ["attachment_id"], name: "index_attachment_items_on_attachment_id", using: :btree
    t.index ["creator_id"], name: "index_attachment_items_on_creator_id", using: :btree
  end

  create_table "attachment_types", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.text     "description"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "type"
    t.string   "simple_chinese_name"
    t.index ["id", "type"], name: "index_attachment_types_on_id_and_type", using: :btree
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "seaweed_hash"
    t.string   "file_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "preview_state"
    t.string   "preview_hash"
  end

  create_table "attend_annual_reports", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "user_id"
    t.integer  "year"
    t.integer  "force_holiday_counts"
    t.integer  "force_holiday_for_leave_counts"
    t.integer  "force_holiday_for_money_counts"
    t.integer  "public_holiday_counts"
    t.integer  "public_holiday_for_leave_counts"
    t.integer  "public_holiday_for_money_counts"
    t.integer  "working_day_counts"
    t.integer  "general_holiday_counts"
    t.integer  "late_mins"
    t.integer  "late_counts"
    t.integer  "late_mins_less_than_10"
    t.integer  "late_mins_less_than_20"
    t.integer  "late_mins_less_than_30"
    t.integer  "late_mins_more_than_30"
    t.integer  "late_mins_more_than_120"
    t.integer  "leave_early_mins"
    t.integer  "leave_early_counts"
    t.integer  "leave_early_mins_not_include_allowable"
    t.integer  "sick_leave_counts_link_off"
    t.integer  "sick_leave_counts_not_link_off"
    t.integer  "annual_leave_counts"
    t.integer  "birthday_leave_counts"
    t.integer  "paid_bonus_leave_counts"
    t.integer  "compensatory_leave_counts"
    t.integer  "paid_sick_leave_counts"
    t.integer  "unpaid_sick_leave_counts"
    t.integer  "unpaid_leave_counts"
    t.integer  "paid_marriage_leave_counts"
    t.integer  "unpaid_marriage_leave_counts"
    t.integer  "paid_compassionate_leave_counts"
    t.integer  "unpaid_compassionate_leave_counts"
    t.integer  "maternity_leave_counts"
    t.integer  "paid_maternity_leave_counts"
    t.integer  "unpaid_maternity_leave_counts"
    t.integer  "immediate_leave_counts"
    t.integer  "absenteeism_counts"
    t.integer  "work_injury_before_7_counts"
    t.integer  "work_injury_after_7_counts"
    t.integer  "unpaid_but_maintain_position_counts"
    t.integer  "overtime_leave_counts"
    t.integer  "absenteeism_from_exception_counts"
    t.integer  "signcard_forget_to_punch_in_counts"
    t.integer  "signcard_forget_to_punch_out_counts"
    t.integer  "signcard_leave_early_counts"
    t.integer  "signcard_work_out_counts"
    t.integer  "signcard_others_counts"
    t.integer  "signcard_typhoon_counts"
    t.integer  "weekdays_overtime_hours"
    t.integer  "general_holiday_overtime_hours"
    t.integer  "force_holiday_overtime_hours"
    t.integer  "public_holiday_overtime_hours"
    t.integer  "vehicle_department_overtime_mins"
    t.integer  "as_a_in_borrow_hours_counts"
    t.integer  "as_b_in_borrow_hours_counts"
    t.integer  "as_a_in_return_hours_counts"
    t.integer  "as_b_in_return_hours_counts"
    t.integer  "typhoon_allowance_counts"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.integer  "pregnant_sick_leave_counts"
    t.integer  "status"
    t.float    "real_working_hours"
    t.decimal  "annual_attend_award",                    precision: 15, scale: 2
    t.index ["department_id"], name: "index_attend_annual_reports_on_department_id", using: :btree
    t.index ["user_id"], name: "index_attend_annual_reports_on_user_id", using: :btree
  end

  create_table "attend_approvals", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "date"
    t.text     "comment"
    t.integer  "approvable_id"
    t.string   "approvable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["approvable_type", "approvable_id"], name: "index_attend_approvals_on_approvable_type_and_approvable_id", using: :btree
    t.index ["user_id"], name: "index_attend_approvals_on_user_id", using: :btree
  end

  create_table "attend_attachments", force: :cascade do |t|
    t.string   "file_name"
    t.integer  "creator_id"
    t.text     "comment"
    t.integer  "attachment_id"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["attachable_type", "attachable_id"], name: "index_attend_attachments_on_attachable_type_and_attachable_id", using: :btree
    t.index ["attachment_id"], name: "index_attend_attachments_on_attachment_id", using: :btree
    t.index ["creator_id"], name: "index_attend_attachments_on_creator_id", using: :btree
  end

  create_table "attend_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "attend_id"
    t.integer  "logger_id"
    t.integer  "apply_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "type_id"
    t.index ["attend_id"], name: "index_attend_logs_on_attend_id", using: :btree
    t.index ["logger_id"], name: "index_attend_logs_on_logger_id", using: :btree
  end

  create_table "attend_month_approvals", force: :cascade do |t|
    t.integer  "status"
    t.integer  "employee_counts"
    t.integer  "roster_counts"
    t.integer  "general_holiday_counts"
    t.integer  "punching_counts"
    t.integer  "punching_exception_counts"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "month"
    t.boolean  "is_settlement"
    t.datetime "approval_time"
    t.integer  "calc_state"
  end

  create_table "attend_monthly_reports", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "user_id"
    t.integer  "year"
    t.integer  "month"
    t.integer  "year_month"
    t.integer  "force_holiday_counts"
    t.integer  "force_holiday_for_leave_counts"
    t.integer  "force_holiday_for_money_counts"
    t.integer  "public_holiday_counts"
    t.integer  "public_holiday_for_leave_counts"
    t.integer  "public_holiday_for_money_counts"
    t.integer  "working_day_counts"
    t.integer  "general_holiday_counts"
    t.integer  "late_mins"
    t.integer  "late_counts"
    t.integer  "late_mins_less_than_10"
    t.integer  "late_mins_less_than_20"
    t.integer  "late_mins_less_than_30"
    t.integer  "late_mins_more_than_30"
    t.integer  "late_mins_more_than_120"
    t.integer  "leave_early_mins"
    t.integer  "leave_early_counts"
    t.integer  "leave_early_mins_not_include_allowable"
    t.integer  "sick_leave_counts_link_off"
    t.integer  "sick_leave_counts_not_link_off"
    t.integer  "annual_leave_counts"
    t.integer  "birthday_leave_counts"
    t.integer  "paid_bonus_leave_counts"
    t.integer  "compensatory_leave_counts"
    t.integer  "paid_sick_leave_counts"
    t.integer  "unpaid_sick_leave_counts"
    t.integer  "unpaid_leave_counts"
    t.integer  "paid_marriage_leave_counts"
    t.integer  "unpaid_marriage_leave_counts"
    t.integer  "paid_compassionate_leave_counts"
    t.integer  "unpaid_compassionate_leave_counts"
    t.integer  "maternity_leave_counts"
    t.integer  "paid_maternity_leave_counts"
    t.integer  "unpaid_maternity_leave_counts"
    t.integer  "immediate_leave_counts"
    t.integer  "absenteeism_counts"
    t.integer  "work_injury_before_7_counts"
    t.integer  "work_injury_after_7_counts"
    t.integer  "unpaid_but_maintain_position_counts"
    t.integer  "overtime_leave_counts"
    t.integer  "absenteeism_from_exception_counts"
    t.integer  "signcard_forget_to_punch_in_counts"
    t.integer  "signcard_forget_to_punch_out_counts"
    t.integer  "signcard_leave_early_counts"
    t.integer  "signcard_work_out_counts"
    t.integer  "signcard_others_counts"
    t.integer  "signcard_typhoon_counts"
    t.integer  "weekdays_overtime_hours"
    t.integer  "general_holiday_overtime_hours"
    t.integer  "force_holiday_overtime_hours"
    t.integer  "public_holiday_overtime_hours"
    t.integer  "vehicle_department_overtime_mins"
    t.integer  "as_a_in_borrow_hours_counts"
    t.integer  "as_b_in_borrow_hours_counts"
    t.integer  "as_a_in_return_hours_counts"
    t.integer  "as_b_in_return_hours_counts"
    t.integer  "typhoon_allowance_counts"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "pregnant_sick_leave_counts"
    t.integer  "status"
    t.float    "real_working_hours"
    t.index ["department_id"], name: "index_attend_monthly_reports_on_department_id", using: :btree
    t.index ["user_id"], name: "index_attend_monthly_reports_on_user_id", using: :btree
  end

  create_table "attend_questionnaire_templates", force: :cascade do |t|
    t.integer "questionnaire_template_id"
    t.integer "attachable_id"
    t.string  "attachable_type"
    t.index ["attachable_id", "attachable_type"], name: "a_q_t", using: :btree
    t.index ["questionnaire_template_id"], name: "index_a_q_t_on_q_t", using: :btree
  end

  create_table "attend_questionnaires", force: :cascade do |t|
    t.integer "questionnaire_id"
    t.integer "attachable_id"
    t.string  "attachable_type"
    t.index ["attachable_type", "attachable_id"], name: "a_q", using: :btree
    t.index ["questionnaire_id"], name: "index_attend_questionnaires_on_questionnaire_id", using: :btree
  end

  create_table "attend_states", force: :cascade do |t|
    t.integer  "attend_id"
    t.integer  "auto_state"
    t.integer  "sign_card_state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "record_type"
    t.integer  "record_id"
    t.string   "remark"
    t.string   "state"
    t.index ["attend_id"], name: "index_attend_states_on_attend_id", using: :btree
  end

  create_table "attendance_item_logs", force: :cascade do |t|
    t.integer  "attendance_item_id"
    t.integer  "user_id"
    t.datetime "log_time"
    t.string   "log_type"
    t.integer  "log_type_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["attendance_item_id"], name: "index_attendance_item_logs_on_attendance_item_id", using: :btree
    t.index ["user_id"], name: "index_attendance_item_logs_on_user_id", using: :btree
  end

  create_table "attendance_items", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "position_id"
    t.integer  "department_id"
    t.integer  "attendance_id"
    t.integer  "shift_id"
    t.datetime "attendance_date"
    t.datetime "start_working_time"
    t.datetime "end_working_time"
    t.text     "comment"
    t.string   "region"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "states",              default: ""
    t.integer  "location_id"
    t.string   "updated_states_from"
    t.integer  "roster_item_id"
    t.datetime "plan_start_time"
    t.datetime "plan_end_time"
    t.boolean  "is_modified"
    t.integer  "overtime_count"
    t.string   "leave_type"
    t.index ["attendance_date"], name: "index_attendance_items_on_attendance_date", using: :btree
    t.index ["attendance_id"], name: "index_attendance_items_on_attendance_id", using: :btree
    t.index ["department_id"], name: "index_attendance_items_on_department_id", using: :btree
    t.index ["location_id"], name: "index_attendance_items_on_location_id", using: :btree
    t.index ["position_id"], name: "index_attendance_items_on_position_id", using: :btree
    t.index ["roster_item_id"], name: "index_attendance_items_on_roster_item_id", using: :btree
    t.index ["shift_id"], name: "index_attendance_items_on_shift_id", using: :btree
    t.index ["user_id"], name: "index_attendance_items_on_user_id", using: :btree
  end

  create_table "attendance_month_report_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "year_month"
    t.decimal  "normal_overtime_hours",                precision: 10, scale: 2
    t.decimal  "holiday_overtime_hours",               precision: 10, scale: 2
    t.decimal  "compulsion_holiday_compensation_days", precision: 10, scale: 2
    t.decimal  "public_holiday_compensation_days",     precision: 10, scale: 2
    t.decimal  "absenteeism_days",                     precision: 10, scale: 2
    t.decimal  "immediate_leave_days",                 precision: 10, scale: 2
    t.decimal  "unpaid_leave_days",                    precision: 10, scale: 2
    t.decimal  "paid_sick_leave_days",                 precision: 10, scale: 2
    t.decimal  "unpaid_marriage_leave_days",           precision: 10, scale: 2
    t.decimal  "unpaid_compassionate_leave_days",      precision: 10, scale: 2
    t.decimal  "unpaid_maternity_leave_days",          precision: 10, scale: 2
    t.decimal  "paid_maternity_leave_days",            precision: 10, scale: 2
    t.decimal  "pregnant_sick_leave_days",             precision: 10, scale: 2
    t.decimal  "occupational_injury_days",             precision: 10, scale: 2
    t.integer  "late_0_10_min_times"
    t.integer  "late_10_20_min_times"
    t.integer  "late_20_30_min_times"
    t.integer  "late_30_120_min_times"
    t.integer  "missing_punch_times"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.index ["user_id"], name: "index_attendance_month_report_items_on_user_id", using: :btree
    t.index ["year_month"], name: "index_attendance_month_report_items_on_year_month", using: :btree
  end

  create_table "attendance_states", force: :cascade do |t|
    t.string   "code"
    t.string   "chinese_name"
    t.string   "english_name"
    t.text     "comment"
    t.integer  "parent_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["code"], name: "index_attendance_states_on_code", using: :btree
    t.index ["parent_id"], name: "index_attendance_states_on_parent_id", using: :btree
  end

  create_table "attendances", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "location_id"
    t.string   "year"
    t.string   "month"
    t.string   "region"
    t.integer  "snapshot_employees_count"
    t.integer  "rosters"
    t.integer  "public_holidays"
    t.integer  "attendance_record"
    t.integer  "unusual_attendances"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "roster_id"
    t.index ["department_id"], name: "index_attendances_on_department_id", using: :btree
    t.index ["location_id"], name: "index_attendances_on_location_id", using: :btree
    t.index ["region"], name: "index_attendances_on_region", using: :btree
    t.index ["roster_id"], name: "index_attendances_on_roster_id", using: :btree
    t.index ["year", "month", "department_id", "location_id"], name: "all", unique: true, using: :btree
    t.index ["year", "month", "department_id"], name: "index_attendances_on_year_and_month_and_department_id", using: :btree
    t.index ["year", "month", "location_id"], name: "index_attendances_on_year_and_month_and_location_id", using: :btree
    t.index ["year", "month"], name: "index_attendances_on_year_and_month", using: :btree
  end

  create_table "attends", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.date     "attend_date"
    t.integer  "attend_weekday"
    t.integer  "roster_object_id"
    t.datetime "on_work_time"
    t.datetime "off_work_time"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["roster_object_id"], name: "index_attends_on_roster_object_id", using: :btree
    t.index ["user_id"], name: "index_attends_on_user_id", using: :btree
  end

  create_table "audiences", force: :cascade do |t|
    t.integer  "applicant_position_id"
    t.integer  "status",                default: 0
    t.text     "comment"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "user_id"
    t.string   "time"
    t.integer  "creator_id"
    t.index ["applicant_position_id"], name: "index_audiences_on_applicant_position_id", using: :btree
    t.index ["creator_id"], name: "index_audiences_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_audiences_on_user_id", using: :btree
  end

  create_table "award_records", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "year"
    t.string   "content"
    t.datetime "award_date"
    t.string   "comment"
    t.integer  "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "reason"
    t.index ["creator_id"], name: "index_award_records_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_award_records_on_user_id", using: :btree
  end

  create_table "background_declarations", force: :cascade do |t|
    t.string   "relative_criminal_record_detail"
    t.string   "relative_business_relationship_with_suncity_detail"
    t.integer  "user_id"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "have_any_relatives"
    t.boolean  "relative_criminal_record"
    t.boolean  "relative_business_relationship_with_suncity"
    t.index ["user_id"], name: "index_background_declarations_on_user_id", using: :btree
  end

  create_table "bank_auto_pay_report_items", force: :cascade do |t|
    t.integer  "record_type"
    t.datetime "year_month"
    t.datetime "balance_date"
    t.integer  "user_id"
    t.decimal  "amount_in_mop",             precision: 15, scale: 2
    t.decimal  "amount_in_hkd",             precision: 15, scale: 2
    t.datetime "begin_work_date"
    t.datetime "end_work_date"
    t.string   "cash_or_check"
    t.boolean  "leave_in_this_month"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "company_name"
    t.integer  "department_id"
    t.integer  "position_id"
    t.string   "position_of_govt_record"
    t.string   "id_number"
    t.string   "bank_of_china_account_mop"
    t.string   "bank_of_china_account_hkd"
    t.index ["department_id"], name: "index_bank_auto_pay_report_items_on_department_id", using: :btree
    t.index ["position_id"], name: "index_bank_auto_pay_report_items_on_position_id", using: :btree
    t.index ["user_id"], name: "index_bank_auto_pay_report_items_on_user_id", using: :btree
  end

  create_table "beneficiaries", force: :cascade do |t|
    t.string   "name"
    t.string   "certificate_type"
    t.string   "id_number"
    t.string   "relationship"
    t.decimal  "percentage",       precision: 15, scale: 2
    t.string   "address"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "bonus_element_item_values", force: :cascade do |t|
    t.integer  "bonus_element_item_id"
    t.integer  "bonus_element_id"
    t.string   "value_type"
    t.decimal  "shares",                precision: 10, scale: 2
    t.decimal  "amount",                precision: 10, scale: 2
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "subtype"
    t.decimal  "basic_salary",          precision: 10, scale: 2
    t.decimal  "per_share",             precision: 15, scale: 4
    t.index ["bonus_element_id"], name: "index_bonus_element_item_values_on_bonus_element_id", using: :btree
    t.index ["bonus_element_item_id"], name: "index_bonus_element_item_values_on_bonus_element_item_id", using: :btree
  end

  create_table "bonus_element_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "float_salary_month_entry_id"
    t.integer  "location_id"
    t.integer  "department_id"
    t.integer  "position_id"
    t.index ["department_id"], name: "index_bonus_element_items_on_department_id", using: :btree
    t.index ["float_salary_month_entry_id"], name: "index_bonus_element_items_on_float_salary_month_entry_id", using: :btree
    t.index ["location_id"], name: "index_bonus_element_items_on_location_id", using: :btree
    t.index ["position_id"], name: "index_bonus_element_items_on_position_id", using: :btree
    t.index ["user_id"], name: "index_bonus_element_items_on_user_id", using: :btree
  end

  create_table "bonus_element_month_amounts", force: :cascade do |t|
    t.integer  "location_id"
    t.integer  "float_salary_month_entry_id"
    t.integer  "bonus_element_id"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "department_id"
    t.string   "level"
    t.string   "subtype"
    t.decimal  "amount",                      precision: 15, scale: 4
    t.index ["bonus_element_id"], name: "index_bonus_element_month_amounts_on_bonus_element_id", using: :btree
    t.index ["department_id"], name: "index_bonus_element_month_amounts_on_department_id", using: :btree
    t.index ["float_salary_month_entry_id"], name: "index_month_bonus_element_amounts_on_float_salary_entry_id", using: :btree
    t.index ["location_id"], name: "index_bonus_element_month_amounts_on_location_id", using: :btree
  end

  create_table "bonus_element_month_personals", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "float_salary_month_entry_id"
    t.integer  "bonus_element_id"
    t.decimal  "amount",                      precision: 10, scale: 2
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.index ["bonus_element_id"], name: "index_bonus_element_month_personals_on_bonus_element_id", using: :btree
    t.index ["float_salary_month_entry_id"], name: "index_month_bonus_element_personals_on_float_salary_entry_id", using: :btree
    t.index ["user_id"], name: "index_bonus_element_month_personals_on_user_id", using: :btree
  end

  create_table "bonus_element_month_shares", force: :cascade do |t|
    t.integer  "location_id"
    t.integer  "float_salary_month_entry_id"
    t.integer  "bonus_element_id"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "department_id"
    t.decimal  "shares",                      precision: 10, scale: 4
    t.index ["bonus_element_id"], name: "index_bonus_element_month_shares_on_bonus_element_id", using: :btree
    t.index ["department_id"], name: "index_bonus_element_month_shares_on_department_id", using: :btree
    t.index ["float_salary_month_entry_id"], name: "index_bonus_element_month_shares_on_float_salary_month_entry_id", using: :btree
    t.index ["location_id"], name: "index_bonus_element_month_shares_on_location_id", using: :btree
  end

  create_table "bonus_element_settings", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "location_id"
    t.integer  "bonus_element_id"
    t.string   "value"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["bonus_element_id"], name: "index_bonus_element_settings_on_bonus_element_id", using: :btree
    t.index ["department_id"], name: "index_bonus_element_settings_on_department_id", using: :btree
    t.index ["location_id"], name: "index_bonus_element_settings_on_location_id", using: :btree
  end

  create_table "bonus_elements", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "key"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.jsonb    "levels"
    t.string   "unit"
    t.integer  "order"
    t.jsonb    "subtypes"
  end

  create_table "candidate_relationships", force: :cascade do |t|
    t.string   "assess_type"
    t.integer  "appraisal_id"
    t.integer  "appraisal_participator_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "candidate_participator_id"
    t.index ["appraisal_id"], name: "index_candidate_relationships_on_appraisal_id", using: :btree
    t.index ["appraisal_participator_id"], name: "index_candidate_relationships_on_appraisal_participator_id", using: :btree
    t.index ["candidate_participator_id"], name: "index_candidate_relationships_on_candidate_participator_id", using: :btree
  end

  create_table "card_attachments", force: :cascade do |t|
    t.string   "category"
    t.string   "file_name"
    t.text     "comment"
    t.integer  "attachment_id"
    t.integer  "card_profile_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "operator_id"
    t.index ["card_profile_id"], name: "index_card_attachments_on_card_profile_id", using: :btree
  end

  create_table "card_histories", force: :cascade do |t|
    t.date     "date_to_get_card"
    t.date     "new_approval_valid_date"
    t.date     "card_valid_date"
    t.date     "certificate_valid_date"
    t.string   "new_or_renew"
    t.integer  "card_profile_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["card_profile_id"], name: "index_card_histories_on_card_profile_id", using: :btree
  end

  create_table "card_profiles", force: :cascade do |t|
    t.string   "photo_id"
    t.string   "empo_chinese_name"
    t.string   "empo_english_name"
    t.string   "empoid"
    t.date     "entry_date"
    t.string   "sex"
    t.string   "nation"
    t.string   "status"
    t.string   "approved_job_name"
    t.string   "approved_job_number"
    t.string   "allocation_company"
    t.date     "allocation_valid_date"
    t.string   "approval_id"
    t.integer  "report_salary_count"
    t.string   "report_salary_unit"
    t.string   "labor_company"
    t.date     "date_to_submit_data"
    t.string   "certificate_type"
    t.string   "certificate_id"
    t.date     "date_to_submit_certificate"
    t.date     "date_to_stamp"
    t.date     "date_to_submit_fingermold"
    t.string   "card_id"
    t.date     "cancel_date"
    t.string   "original_user"
    t.text     "comment"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.date     "new_approval_valid_date"
    t.string   "new_or_renew"
    t.date     "certificate_valid_date"
    t.date     "date_to_get_card"
    t.date     "card_valid_date"
    t.integer  "user_id"
    t.index ["user_id"], name: "index_card_profiles_on_user_id", using: :btree
  end

  create_table "card_records", force: :cascade do |t|
    t.string   "key"
    t.string   "action_type"
    t.integer  "current_user_id"
    t.string   "field_key"
    t.string   "file_category"
    t.json     "value1"
    t.json     "value2"
    t.json     "value"
    t.integer  "card_profile_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["card_profile_id"], name: "index_card_records_on_card_profile_id", using: :btree
    t.index ["current_user_id"], name: "index_card_records_on_current_user_id", using: :btree
  end

  create_table "career_records", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "career_begin"
    t.datetime "career_end"
    t.string   "deployment_type"
    t.datetime "trial_period_expiration_date"
    t.string   "salary_calculation"
    t.string   "company_name"
    t.integer  "location_id"
    t.integer  "position_id"
    t.integer  "department_id"
    t.integer  "grade"
    t.string   "division_of_job"
    t.string   "deployment_instructions"
    t.integer  "inputer_id"
    t.string   "comment"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "employment_status"
    t.datetime "valid_date"
    t.datetime "invalid_date"
    t.string   "order_key"
    t.integer  "group_id"
    t.index ["career_begin"], name: "index_career_records_on_career_begin", using: :btree
    t.index ["career_end"], name: "index_career_records_on_career_end", using: :btree
    t.index ["department_id"], name: "index_career_records_on_department_id", using: :btree
    t.index ["group_id"], name: "index_career_records_on_group_id", using: :btree
    t.index ["inputer_id"], name: "index_career_records_on_inputer_id", using: :btree
    t.index ["invalid_date"], name: "index_career_records_on_invalid_date", using: :btree
    t.index ["position_id"], name: "index_career_records_on_position_id", using: :btree
    t.index ["user_id"], name: "index_career_records_on_user_id", using: :btree
    t.index ["valid_date"], name: "index_career_records_on_valid_date", using: :btree
  end

  create_table "choice_questions", force: :cascade do |t|
    t.integer  "questionnaire_id"
    t.integer  "questionnaire_template_id"
    t.integer  "order_no"
    t.text     "question"
    t.integer  "answer",                    default: [],              array: true
    t.boolean  "is_multiple"
    t.boolean  "is_required"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "value"
    t.integer  "score"
    t.text     "annotation"
    t.integer  "right_answer",              default: [],              array: true
    t.boolean  "is_filled_in"
    t.index ["questionnaire_id"], name: "index_choice_questions_on_questionnaire_id", using: :btree
    t.index ["questionnaire_template_id"], name: "index_choice_questions_on_questionnaire_template_id", using: :btree
  end

  create_table "class_people_preferences", force: :cascade do |t|
    t.integer  "roster_preference_id"
    t.integer  "class_setting_id"
    t.integer  "max_of_total"
    t.integer  "min_of_total"
    t.integer  "max_of_manager_level"
    t.integer  "min_of_manager_level"
    t.integer  "max_of_director_level"
    t.integer  "min_of_director_level"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["roster_preference_id"], name: "index_class_people_preferences_on_roster_preference_id", using: :btree
  end

  create_table "class_settings", force: :cascade do |t|
    t.string   "region"
    t.integer  "department_id"
    t.string   "name"
    t.string   "display_name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "late_be_allowed"
    t.integer  "leave_be_allowed"
    t.integer  "overtime_before_work"
    t.integer  "overtime_after_work"
    t.boolean  "be_used"
    t.integer  "be_used_count",        default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "is_next_of_start"
    t.boolean  "is_next_of_end"
    t.string   "new_code"
    t.string   "code"
    t.index ["department_id"], name: "index_class_settings_on_department_id", using: :btree
  end

  create_table "classes_between_general_holiday_preferences", force: :cascade do |t|
    t.integer  "roster_preference_id"
    t.integer  "position_id"
    t.integer  "max_classes_count"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["roster_preference_id"], name: "roster_preference_index", using: :btree
  end

  create_table "client_comment_tracks", force: :cascade do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "track_date"
    t.integer  "client_comment_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["client_comment_id"], name: "index_client_comment_tracks_on_client_comment_id", using: :btree
    t.index ["user_id"], name: "index_client_comment_tracks_on_user_id", using: :btree
  end

  create_table "client_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "client_account"
    t.string   "client_name"
    t.datetime "client_fill_in_date"
    t.string   "client_phone"
    t.datetime "client_account_date"
    t.string   "involving_staff"
    t.datetime "event_time_start"
    t.datetime "event_time_end"
    t.string   "event_place"
    t.integer  "last_tracker_id"
    t.datetime "last_track_date"
    t.string   "last_track_content"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "questionnaire_template_id"
    t.integer  "questionnaire_id"
    t.index ["last_tracker_id"], name: "index_client_comments_on_last_tracker_id", using: :btree
    t.index ["user_id"], name: "index_client_comments_on_user_id", using: :btree
  end

  create_table "compensate_reports", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "user_id"
    t.integer  "year"
    t.integer  "month"
    t.integer  "year_month"
    t.integer  "record_type"
    t.integer  "force_holiday_counts"
    t.integer  "force_holiday_for_leave_counts"
    t.integer  "force_holiday_for_money_counts"
    t.integer  "public_holiday_counts"
    t.integer  "public_holiday_for_leave_counts"
    t.integer  "public_holiday_for_money_counts"
    t.integer  "working_day_counts"
    t.integer  "general_holiday_counts"
    t.integer  "late_mins"
    t.integer  "late_counts"
    t.integer  "late_mins_less_than_10"
    t.integer  "late_mins_less_than_20"
    t.integer  "late_mins_less_than_30"
    t.integer  "late_mins_more_than_30"
    t.integer  "late_mins_more_than_120"
    t.integer  "leave_early_mins"
    t.integer  "leave_early_counts"
    t.integer  "leave_early_mins_not_include_allowable"
    t.integer  "sick_leave_counts_link_off"
    t.integer  "sick_leave_counts_not_link_off"
    t.integer  "annual_leave_counts"
    t.integer  "birthday_leave_counts"
    t.integer  "paid_bonus_leave_counts"
    t.integer  "compensatory_leave_counts"
    t.integer  "paid_sick_leave_counts"
    t.integer  "unpaid_sick_leave_counts"
    t.integer  "unpaid_leave_counts"
    t.integer  "paid_marriage_leave_counts"
    t.integer  "unpaid_marriage_leave_counts"
    t.integer  "paid_compassionate_leave_counts"
    t.integer  "unpaid_compassionate_leave_counts"
    t.integer  "maternity_leave_counts"
    t.integer  "paid_maternity_leave_counts"
    t.integer  "unpaid_maternity_leave_counts"
    t.integer  "immediate_leave_counts"
    t.integer  "absenteeism_counts"
    t.integer  "work_injury_before_7_counts"
    t.integer  "work_injury_after_7_counts"
    t.integer  "unpaid_but_maintain_position_counts"
    t.integer  "overtime_leave_counts"
    t.integer  "absenteeism_from_exception_counts"
    t.integer  "signcard_forget_to_punch_in_counts"
    t.integer  "signcard_forget_to_punch_out_counts"
    t.integer  "signcard_leave_early_counts"
    t.integer  "signcard_work_out_counts"
    t.integer  "signcard_others_counts"
    t.integer  "signcard_typhoon_counts"
    t.integer  "weekdays_overtime_hours"
    t.integer  "general_holiday_overtime_hours"
    t.integer  "force_holiday_overtime_hours"
    t.integer  "public_holiday_overtime_hours"
    t.integer  "vehicle_department_overtime_mins"
    t.integer  "as_a_in_borrow_hours_counts"
    t.integer  "as_b_in_borrow_hours_counts"
    t.integer  "as_a_in_return_hours_counts"
    t.integer  "as_b_in_return_hours_counts"
    t.integer  "typhoon_allowance_counts"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "pregnant_sick_leave_counts"
    t.string   "pair_sort_key"
    t.float    "real_working_hours"
    t.index ["department_id"], name: "index_compensate_reports_on_department_id", using: :btree
    t.index ["user_id"], name: "index_compensate_reports_on_user_id", using: :btree
  end

  create_table "contract_information_types", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.text     "description"
    t.string   "type"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "simple_chinese_name"
  end

  create_table "contract_informations", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "contract_information_type_id"
    t.integer  "attachment_id"
    t.text     "description"
    t.integer  "creator_id"
    t.string   "file_name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["attachment_id"], name: "index_contract_informations_on_attachment_id", using: :btree
    t.index ["contract_information_type_id"], name: "index_contract_informations_on_contract_information_type_id", using: :btree
    t.index ["creator_id"], name: "index_contract_informations_on_creator_id", using: :btree
    t.index ["profile_id"], name: "index_contract_informations_on_profile_id", using: :btree
  end

  create_table "contracts", force: :cascade do |t|
    t.integer  "applicant_position_id"
    t.string   "time"
    t.text     "comment"
    t.integer  "status"
    t.text     "cancel_reason"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["applicant_position_id"], name: "index_contracts_on_applicant_position_id", using: :btree
  end

  create_table "contribution_report_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "year_month"
    t.decimal  "relevant_income",                                  precision: 15, scale: 2
    t.decimal  "employee_voluntary_contribution_percentage",       precision: 15, scale: 2
    t.decimal  "employee_voluntary_contribution_amount",           precision: 15, scale: 2
    t.decimal  "percentage_of_voluntary_contributions_of_members", precision: 15, scale: 2
    t.decimal  "membership_voluntary_contributions_amount",        precision: 15, scale: 2
    t.decimal  "employer_contribution_percentage",                 precision: 15, scale: 2
    t.decimal  "employer_contribution_count",                      precision: 15, scale: 2
    t.decimal  "percentage_of_contribution_of_members",            precision: 15, scale: 2
    t.decimal  "percentage_of_contribution_of_governmment",        precision: 15, scale: 2
    t.decimal  "count_of_contribution_of_governmment",             precision: 15, scale: 2
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.integer  "department_id"
    t.integer  "position_id"
    t.integer  "grade"
    t.string   "member_retirement_fund_number"
    t.index ["department_id"], name: "index_contribution_report_items_on_department_id", using: :btree
    t.index ["position_id"], name: "index_contribution_report_items_on_position_id", using: :btree
    t.index ["user_id"], name: "index_contribution_report_items_on_user_id", using: :btree
  end

  create_table "department_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "department_anc_desc_idx", unique: true, using: :btree
    t.index ["descendant_id"], name: "department_desc_idx", using: :btree
  end

  create_table "department_statuses", force: :cascade do |t|
    t.datetime "year_month"
    t.integer  "employees_on_duty"
    t.integer  "employees_left_this_month"
    t.integer  "employees_left_last_day"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "department_id"
    t.integer  "float_salary_month_entry_id"
    t.index ["department_id"], name: "index_department_statuses_on_department_id", using: :btree
    t.index ["float_salary_month_entry_id"], name: "index_department_statuses_on_float_salary_month_entry_id", using: :btree
  end

  create_table "departments", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.text     "comment"
    t.string   "region_key"
    t.integer  "parent_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "status",              default: 0
    t.integer  "head_id"
    t.string   "simple_chinese_name"
    t.index ["head_id"], name: "index_departments_on_head_id", using: :btree
    t.index ["parent_id"], name: "index_departments_on_parent_id", using: :btree
  end

  create_table "departments_groups", id: false, force: :cascade do |t|
    t.integer "department_id", null: false
    t.integer "group_id",      null: false
    t.index ["department_id", "group_id"], name: "index_departments_groups_on_department_id_and_group_id", using: :btree
  end

  create_table "departments_locations", id: false, force: :cascade do |t|
    t.integer "department_id", null: false
    t.integer "location_id",   null: false
    t.index ["department_id", "location_id"], name: "index_departments_locations_on_department_id_and_location_id", using: :btree
  end

  create_table "departments_positions", id: false, force: :cascade do |t|
    t.integer "department_id", null: false
    t.integer "position_id",   null: false
    t.index ["department_id", "position_id"], name: "index_departments_positions_on_department_id_and_position_id", using: :btree
  end

  create_table "departments_train_classes", id: false, force: :cascade do |t|
    t.integer "train_class_id", null: false
    t.integer "department_id",  null: false
    t.index ["train_class_id", "department_id"], name: "index_on_join_table_departments_train_classes", using: :btree
  end

  create_table "departments_trains", id: false, force: :cascade do |t|
    t.integer "train_id",      null: false
    t.integer "department_id", null: false
    t.index ["train_id", "department_id"], name: "index_departments_trains_on_train_id_and_department_id", using: :btree
  end

  create_table "departure_employee_taxpayer_numbering_report_items", force: :cascade do |t|
    t.datetime "year_month"
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "beneficiary_name"
    t.string   "deployer_retirement_fund_number"
    t.index ["user_id"], name: "departure_employee_taxpayer_on_user_id", using: :btree
  end

  create_table "dimission_appointments", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "status"
    t.integer  "questionnaire_template_id"
    t.integer  "questionnaire_id"
    t.date     "last_working_date"
    t.string   "duration"
    t.boolean  "had_transfer"
    t.date     "last_transfer_date"
    t.date     "appointment_date"
    t.string   "appointment_time"
    t.string   "appointment_location"
    t.text     "appointment_description"
    t.text     "opinion"
    t.text     "other_opinion"
    t.text     "summary"
    t.integer  "inputter_id"
    t.date     "input_date"
    t.string   "comment"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["inputter_id"], name: "index_dimission_appointments_on_inputter_id", using: :btree
    t.index ["user_id"], name: "index_dimission_appointments_on_user_id", using: :btree
  end

  create_table "dimission_follow_ups", force: :cascade do |t|
    t.integer  "dimission_id"
    t.string   "event_key"
    t.integer  "return_number"
    t.decimal  "compensation",  precision: 10, scale: 2
    t.boolean  "is_confirmed"
    t.integer  "handler_id"
    t.boolean  "is_checked"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["dimission_id"], name: "index_dimission_follow_ups_on_dimission_id", using: :btree
    t.index ["handler_id"], name: "index_dimission_follow_ups_on_handler_id", using: :btree
  end

  create_table "dimissions", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "apply_date"
    t.date     "inform_date"
    t.date     "last_work_date"
    t.boolean  "is_in_blacklist"
    t.text     "comment"
    t.date     "last_salary_begin_date"
    t.date     "last_salary_end_date"
    t.integer  "remaining_annual_holidays"
    t.text     "apply_comment"
    t.jsonb    "resignation_reason"
    t.string   "resignation_reason_extra"
    t.jsonb    "resignation_future_plan"
    t.string   "resignation_future_plan_extra"
    t.boolean  "resignation_is_inform_period_exempted"
    t.integer  "resignation_inform_period_penalty"
    t.boolean  "resignation_is_recommanded_to_other_department"
    t.jsonb    "termination_reason"
    t.string   "termination_reason_extra"
    t.integer  "termination_inform_peroid_days"
    t.boolean  "termination_is_reasonable"
    t.string   "termination_compensation_extra"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "dimission_type"
    t.integer  "creator_id"
    t.date     "holiday_cut_off_date"
    t.jsonb    "resignation_certificate_languages"
    t.string   "career_history_dimission_reason",                null: false
    t.text     "career_history_dimission_comment"
    t.integer  "termination_compensation"
    t.string   "company_name"
    t.datetime "final_work_date"
    t.boolean  "is_compensation_year"
    t.boolean  "notice_period_compensation"
    t.integer  "group_id"
    t.index ["creator_id"], name: "index_dimissions_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_dimissions_on_user_id", using: :btree
  end

  create_table "dismission_salary_items", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "dimission_id"
    t.decimal  "base_salary_hkd",                            precision: 15, scale: 2
    t.decimal  "benefits_hkd",                               precision: 15, scale: 2
    t.decimal  "annual_incentive_hkd",                       precision: 15, scale: 2
    t.decimal  "housing_benefits_hkd",                       precision: 15, scale: 2
    t.decimal  "seniority_compensation_hkd",                 precision: 15, scale: 2
    t.decimal  "dismission_annual_holiday_compensation_hkd", precision: 15, scale: 2
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.decimal  "dismission_inform_period_compensation_hkd",  precision: 15, scale: 2
    t.boolean  "has_seniority_compensation"
    t.boolean  "has_inform_period_compensation"
    t.boolean  "approved"
    t.index ["dimission_id"], name: "index_dismission_salary_items_on_dimission_id", using: :btree
    t.index ["user_id"], name: "index_dismission_salary_items_on_user_id", using: :btree
  end

  create_table "education_informations", force: :cascade do |t|
    t.string   "college_university"
    t.string   "educational_department"
    t.string   "graduate_level"
    t.string   "diploma_degree_attained"
    t.date     "certificate_issue_date"
    t.boolean  "graduated"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "from_mm_yyyy"
    t.datetime "to_mm_yyyy"
    t.integer  "profile_id"
    t.integer  "creator_id"
    t.boolean  "highest"
    t.index ["creator_id"], name: "index_education_informations_on_creator_id", using: :btree
    t.index ["profile_id"], name: "index_education_informations_on_profile_id", using: :btree
  end

  create_table "email_objects", force: :cascade do |t|
    t.jsonb    "to"
    t.string   "subject"
    t.text     "body"
    t.string   "the_object"
    t.integer  "the_object_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "status",        default: 0
    t.string   "mark"
  end

  create_table "employee_fund_switching_report_items", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "pension_fund_name_in_employer_contribution"
    t.decimal  "contribution_allocation_percentage_in_employer_contribution",     precision: 10, scale: 2
    t.string   "name_of_fund_to_be_redeemed_in_employer_contribution"
    t.decimal  "percentage_in_employer_contribution",                             precision: 10, scale: 2
    t.string   "name_of_fund_to_be_allocated_in_employer_contribution"
    t.string   "pension_fund_name_in_employer_voluntary_contribution"
    t.decimal  "contribution_allocation_percentage_in_employer_voluntary_contri", precision: 10, scale: 2
    t.string   "name_of_fund_to_be_redeemed_in_employer_voluntary_contribution"
    t.decimal  "percentage_in_employer_voluntary_contribution",                   precision: 10, scale: 2
    t.string   "name_of_fund_to_be_allocated_in_employer_voluntary_contribution"
    t.string   "pension_fund_name_in_employee_contribution"
    t.decimal  "contribution_allocation_percentage_in_employee_contribution",     precision: 10, scale: 2
    t.string   "name_of_fund_to_be_redeemed_in_employee_contribution"
    t.decimal  "percentage_in_employee_contribution",                             precision: 10, scale: 2
    t.string   "name_of_fund_to_be_allocated_in_employee_contribution"
    t.string   "pension_fund_name_in_employee_voluntary_contribution"
    t.decimal  "contribution_allocation_percentage_in_employee_voluntary_contri", precision: 10, scale: 2
    t.string   "name_of_fund_to_be_redeemed_in_employee_voluntary_contribution"
    t.decimal  "percentage_in_employee_voluntary_contribution",                   precision: 10, scale: 2
    t.string   "name_of_fund_to_be_allocated_in_employee_voluntary_contribution"
    t.string   "pension_fund_name_in_government_contribution"
    t.decimal  "contribution_allocation_percentage_in_government_contribution",   precision: 10, scale: 2
    t.string   "name_of_fund_to_be_redeemed_in_government_contribution"
    t.decimal  "percentage_in_government_contribution",                           precision: 10, scale: 2
    t.string   "name_of_fund_to_be_allocated_in_government_contribution"
    t.datetime "created_at",                                                                               null: false
    t.datetime "updated_at",                                                                               null: false
    t.index ["user_id"], name: "index_employee_fund_switching_report_items_on_user_id", using: :btree
  end

  create_table "employee_general_holiday_preferences", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "employee_preference_id"
    t.string   "date_range"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "day_group",              default: [],              array: true
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["employee_preference_id"], name: "general_holiday_employee_preference_index", using: :btree
  end

  create_table "employee_preferences", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "roster_preference_id"
    t.index ["roster_preference_id"], name: "index_employee_preferences_on_roster_preference_id", using: :btree
    t.index ["user_id"], name: "index_employee_preferences_on_user_id", using: :btree
  end

  create_table "employee_redemption_report_items", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "contribution_item"
    t.decimal  "vesting_percentage"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["user_id"], name: "index_employee_redemption_report_items_on_user_id", using: :btree
  end

  create_table "employee_roster_preferences", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "employee_preference_id"
    t.string   "date_range"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "class_setting_group",    default: [],              array: true
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["employee_preference_id"], name: "index_employee_roster_preferences_on_employee_preference_id", using: :btree
  end

  create_table "empo_cards", force: :cascade do |t|
    t.string   "approved_job_name"
    t.string   "approved_job_number"
    t.date     "approval_valid_date"
    t.integer  "report_salary_count"
    t.string   "report_salary_unit"
    t.date     "allocation_valid_date"
    t.integer  "approved_number"
    t.integer  "used_number"
    t.string   "operator_name"
    t.integer  "approved_job_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["approved_job_id"], name: "index_empo_cards_on_approved_job_id", using: :btree
  end

  create_table "entry_appointments", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "status"
    t.integer  "questionnaire_template_id"
    t.integer  "questionnaire_id"
    t.date     "appointment_date"
    t.string   "appointment_time"
    t.string   "appointment_location"
    t.text     "appointment_description"
    t.text     "opinion"
    t.text     "other_opinion"
    t.text     "summary"
    t.integer  "inputter_id"
    t.date     "input_date"
    t.string   "comment"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["inputter_id"], name: "index_entry_appointments_on_inputter_id", using: :btree
    t.index ["user_id"], name: "index_entry_appointments_on_user_id", using: :btree
  end

  create_table "entry_lists", force: :cascade do |t|
    t.datetime "registration_time"
    t.integer  "user_id"
    t.boolean  "is_can_be_absent"
    t.integer  "working_status"
    t.integer  "title_id"
    t.integer  "is_in_working_time"
    t.integer  "registration_status"
    t.string   "change_reason"
    t.integer  "train_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "creator_id"
    t.index ["creator_id"], name: "index_entry_lists_on_creator_id", using: :btree
    t.index ["title_id"], name: "index_entry_lists_on_title_id", using: :btree
    t.index ["train_id"], name: "index_entry_lists_on_train_id", using: :btree
    t.index ["user_id"], name: "index_entry_lists_on_user_id", using: :btree
  end

  create_table "exception_logs", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "family_declaration_items", force: :cascade do |t|
    t.string   "relative_relation"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "profile_id"
    t.integer  "creator_id"
    t.integer  "family_member_id"
    t.index ["creator_id"], name: "index_family_declaration_items_on_creator_id", using: :btree
    t.index ["profile_id"], name: "index_family_declaration_items_on_profile_id", using: :btree
  end

  create_table "family_member_informations", force: :cascade do |t|
    t.string   "family_fathers_name_chinese"
    t.string   "family_fathers_name_english"
    t.string   "family_mothers_name_chinese"
    t.string   "family_mothers_name_english"
    t.string   "family_partenrs_name_chinese"
    t.string   "family_partenrs_name_english"
    t.string   "family_kids_name_chinese"
    t.string   "family_kids_name_english"
    t.string   "family_bothers_name_chinese"
    t.string   "family_bothers_name_english"
    t.string   "family_sisters_name_chinese"
    t.string   "family_sisters_name_english"
    t.string   "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["user_id"], name: "index_family_member_informations_on_user_id", using: :btree
  end

  create_table "fill_in_the_blank_questions", force: :cascade do |t|
    t.integer  "questionnaire_id"
    t.integer  "questionnaire_template_id"
    t.integer  "order_no"
    t.text     "question"
    t.text     "answer"
    t.boolean  "is_required"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "value"
    t.integer  "score"
    t.text     "annotation"
    t.text     "right_answer"
    t.boolean  "is_filled_in"
    t.index ["questionnaire_id"], name: "index_fill_in_the_blank_questions_on_questionnaire_id", using: :btree
    t.index ["questionnaire_template_id"], name: "index_fill_in_the_blank_questions_on_questionnaire_template_id", using: :btree
  end

  create_table "final_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "working_status"
    t.decimal  "cost",                  precision: 15, scale: 2
    t.integer  "train_result"
    t.decimal  "attendance_percentage", precision: 15, scale: 2
    t.decimal  "test_score",            precision: 15, scale: 2
    t.integer  "train_id"
    t.integer  "entry_list_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "comment"
    t.index ["entry_list_id"], name: "index_final_lists_on_entry_list_id", using: :btree
    t.index ["train_id"], name: "index_final_lists_on_train_id", using: :btree
    t.index ["user_id"], name: "index_final_lists_on_user_id", using: :btree
  end

  create_table "final_lists_train_classes", id: false, force: :cascade do |t|
    t.integer "final_list_id",  null: false
    t.integer "train_class_id", null: false
    t.index ["final_list_id", "train_class_id"], name: "indexes_f_id_and_t_id", using: :btree
  end

  create_table "float_salary_month_entries", force: :cascade do |t|
    t.datetime "year_month"
    t.string   "status"
    t.integer  "employees_count"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "force_holiday_working_records", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "holiday_setting_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "attend_id"
    t.index ["attend_id"], name: "index_force_holiday_working_records_on_attend_id", using: :btree
    t.index ["holiday_setting_id"], name: "index_force_holiday_working_records_on_holiday_setting_id", using: :btree
    t.index ["user_id"], name: "index_force_holiday_working_records_on_user_id", using: :btree
  end

  create_table "general_holiday_interval_preferences", force: :cascade do |t|
    t.integer  "roster_preference_id"
    t.integer  "position_id"
    t.integer  "max_interval_days"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["roster_preference_id"], name: "interval_preferences_roster_preference_index", using: :btree
  end

  create_table "goods_categories", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "unit"
    t.decimal  "price_mop",           precision: 15, scale: 2
    t.integer  "distributed_count"
    t.integer  "returned_count"
    t.integer  "unreturned_count"
    t.integer  "user_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.index ["user_id"], name: "index_goods_categories_on_user_id", using: :btree
  end

  create_table "goods_category_managements", force: :cascade do |t|
    t.string   "chinese_name",                                 null: false
    t.string   "english_name",                                 null: false
    t.string   "simple_chinese_name",                          null: false
    t.string   "unit",                                         null: false
    t.decimal  "unit_price",          precision: 10, scale: 2, null: false
    t.integer  "distributed_number"
    t.integer  "collected_number"
    t.integer  "unreturned_number"
    t.integer  "creator_id"
    t.datetime "create_date"
    t.boolean  "can_be_delete"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.index ["chinese_name"], name: "index_goods_category_managements_on_chinese_name", using: :btree
    t.index ["collected_number"], name: "index_goods_category_managements_on_collected_number", using: :btree
    t.index ["create_date"], name: "index_goods_category_managements_on_create_date", using: :btree
    t.index ["creator_id"], name: "index_goods_category_managements_on_creator_id", using: :btree
    t.index ["distributed_number"], name: "index_goods_category_managements_on_distributed_number", using: :btree
    t.index ["english_name"], name: "index_goods_category_managements_on_english_name", using: :btree
    t.index ["simple_chinese_name"], name: "index_goods_category_managements_on_simple_chinese_name", using: :btree
    t.index ["unit"], name: "index_goods_category_managements_on_unit", using: :btree
    t.index ["unit_price"], name: "index_goods_category_managements_on_unit_price", using: :btree
    t.index ["unreturned_number"], name: "index_goods_category_managements_on_unreturned_number", using: :btree
  end

  create_table "goods_signings", force: :cascade do |t|
    t.datetime "distribution_date"
    t.string   "goods_status"
    t.integer  "user_id"
    t.integer  "goods_category_id"
    t.integer  "distribution_count"
    t.decimal  "distribution_total_value", precision: 15, scale: 2
    t.datetime "sign_date"
    t.datetime "return_date"
    t.integer  "distributor_id"
    t.string   "remarks"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.index ["distributor_id"], name: "index_goods_signings_on_distributor_id", using: :btree
    t.index ["goods_category_id"], name: "index_goods_signings_on_goods_category_id", using: :btree
    t.index ["user_id"], name: "index_goods_signings_on_user_id", using: :btree
  end

  create_table "grant_type_details", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "add_basic_salary"
    t.integer  "basic_salary_time"
    t.boolean  "add_bonus"
    t.integer  "bonus_time"
    t.boolean  "add_attendance_bonus"
    t.integer  "attendance_bonus_time"
    t.boolean  "add_fixed_award"
    t.decimal  "fixed_award_mop",        precision: 15, scale: 2
    t.integer  "annual_award_report_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "region_key"
    t.boolean  "can_be_destroy",      default: true
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "holiday_items", force: :cascade do |t|
    t.integer  "holiday_id"
    t.integer  "creator_id"
    t.integer  "status"
    t.integer  "holiday_type"
    t.date     "start_time"
    t.date     "end_time"
    t.integer  "duration"
    t.text     "comment"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["holiday_id"], name: "index_holiday_items_on_holiday_id", using: :btree
  end

  create_table "holiday_records", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.boolean  "is_compensate"
    t.date     "start_date"
    t.datetime "start_time"
    t.date     "end_date"
    t.datetime "end_time"
    t.integer  "days_count"
    t.integer  "hours_count"
    t.integer  "year"
    t.boolean  "is_deleted"
    t.text     "comment"
    t.integer  "creator_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "source_id"
    t.date     "input_date"
    t.string   "input_time"
    t.integer  "reserved_holiday_setting_id"
    t.string   "holiday_type"
    t.integer  "change_to_general_holiday_count"
    t.index ["creator_id"], name: "index_holiday_records_on_creator_id", using: :btree
    t.index ["reserved_holiday_setting_id"], name: "index_holiday_records_on_reserved_holiday_setting_id", using: :btree
    t.index ["user_id"], name: "index_holiday_records_on_user_id", using: :btree
  end

  create_table "holiday_settings", force: :cascade do |t|
    t.string   "region"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.integer  "category"
    t.date     "holiday_date"
    t.text     "comment"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "holiday_surplus_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "last_year_surplus"
    t.integer  "total"
    t.integer  "used"
    t.integer  "surplus"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["user_id"], name: "index_holiday_surplus_reports_on_user_id", using: :btree
  end

  create_table "holiday_switch_items", force: :cascade do |t|
    t.integer  "holiday_switch_id"
    t.integer  "type"
    t.integer  "user_id"
    t.integer  "user_b_id"
    t.date     "a_date"
    t.date     "b_date"
    t.string   "a_start"
    t.string   "a_end"
    t.string   "b_start"
    t.string   "b_end"
    t.integer  "status",            default: 1, null: false
    t.text     "comment"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "a_type"
    t.string   "b_type"
    t.index ["holiday_switch_id"], name: "index_holiday_switch_items_on_holiday_switch_id", using: :btree
    t.index ["user_b_id"], name: "index_holiday_switch_items_on_user_b_id", using: :btree
    t.index ["user_id"], name: "index_holiday_switch_items_on_user_id", using: :btree
  end

  create_table "holiday_switches", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_b_id"
    t.integer  "creator_id"
    t.integer  "status",      default: 1,                null: false
    t.text     "comment"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "record_type", default: "holiday_switch", null: false
    t.index ["creator_id"], name: "index_holiday_switches_on_creator_id", using: :btree
    t.index ["user_b_id"], name: "index_holiday_switches_on_user_b_id", using: :btree
    t.index ["user_id"], name: "index_holiday_switches_on_user_id", using: :btree
  end

  create_table "holidays", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "item_count"
    t.integer  "status",     default: 1, null: false
    t.integer  "category",   default: 1, null: false
    t.datetime "apply_time"
    t.text     "comment"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id"], name: "index_holidays_on_user_id", using: :btree
  end

  create_table "immediate_leave_items", force: :cascade do |t|
    t.integer  "immediate_leave_id"
    t.text     "comment"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.date     "date"
    t.string   "shift_info"
    t.string   "work_time"
    t.string   "come"
    t.string   "leave"
    t.index ["immediate_leave_id"], name: "index_immediate_leave_items_on_immediate_leave_id", using: :btree
  end

  create_table "immediate_leaves", force: :cascade do |t|
    t.date     "date"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "status",      default: 1,                 null: false
    t.integer  "item_count"
    t.text     "comment"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "record_type", default: "immediate_leave", null: false
    t.index ["creator_id"], name: "index_immediate_leaves_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_immediate_leaves_on_user_id", using: :btree
  end

  create_table "interviewers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "interview_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "status",                default: 4
    t.text     "comment"
    t.integer  "creator_id"
    t.integer  "applicant_position_id"
    t.index ["applicant_position_id"], name: "index_interviewers_on_applicant_position_id", using: :btree
    t.index ["creator_id"], name: "index_interviewers_on_creator_id", using: :btree
    t.index ["interview_id"], name: "index_interviewers_on_interview_id", using: :btree
    t.index ["user_id"], name: "index_interviewers_on_user_id", using: :btree
  end

  create_table "interviews", force: :cascade do |t|
    t.integer  "applicant_position_id"
    t.string   "time"
    t.text     "comment"
    t.integer  "result",                default: 4
    t.integer  "score",                 default: 0
    t.text     "evaluation"
    t.integer  "need_again",            default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "mark"
    t.text     "cancel_reason"
    t.index ["applicant_position_id"], name: "index_interviews_on_applicant_position_id", using: :btree
  end

  create_table "job_transfers", force: :cascade do |t|
    t.string   "region"
    t.date     "apply_date"
    t.integer  "user_id"
    t.integer  "transfer_type"
    t.date     "position_start_date"
    t.date     "position_end_date"
    t.boolean  "apply_result"
    t.date     "trial_expiration_date"
    t.integer  "new_location_id"
    t.integer  "new_department_id"
    t.integer  "new_position_id"
    t.integer  "new_grade"
    t.string   "instructions"
    t.integer  "original_location_id"
    t.integer  "original_department_id"
    t.integer  "original_position_id"
    t.integer  "original_grade"
    t.integer  "inputter_id"
    t.date     "input_date"
    t.string   "comment"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "new_company_name"
    t.string   "original_company_name"
    t.string   "new_employment_status"
    t.string   "original_employment_status"
    t.string   "salary_calculation"
    t.integer  "transferable_id"
    t.string   "transferable_type"
    t.integer  "new_group_id"
    t.integer  "original_group_id"
    t.index ["inputter_id"], name: "index_job_transfers_on_inputter_id", using: :btree
    t.index ["new_department_id"], name: "index_job_transfers_on_new_department_id", using: :btree
    t.index ["new_location_id"], name: "index_job_transfers_on_new_location_id", using: :btree
    t.index ["new_position_id"], name: "index_job_transfers_on_new_position_id", using: :btree
    t.index ["original_department_id"], name: "index_job_transfers_on_original_department_id", using: :btree
    t.index ["original_location_id"], name: "index_job_transfers_on_original_location_id", using: :btree
    t.index ["original_position_id"], name: "index_job_transfers_on_original_position_id", using: :btree
    t.index ["transferable_id", "transferable_type"], name: "index_job_transfers_on_transferable_id_and_transferable_type", using: :btree
    t.index ["user_id"], name: "index_job_transfers_on_user_id", using: :btree
  end

  create_table "jobs", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "position_id"
    t.string   "superior_email"
    t.string   "grade"
    t.integer  "number"
    t.text     "chinese_range"
    t.text     "english_range"
    t.text     "chinese_skill"
    t.text     "english_skill"
    t.text     "chinese_education"
    t.text     "english_education"
    t.integer  "status",            default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "region"
    t.integer  "need_number"
    t.index ["department_id"], name: "index_jobs_on_department_id", using: :btree
    t.index ["position_id"], name: "index_jobs_on_position_id", using: :btree
  end

  create_table "language_skills", force: :cascade do |t|
    t.string   "language_other_name"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "language_chinese_writing"
    t.string   "language_contanese_speaking"
    t.string   "language_contanese_listening"
    t.string   "language_mandarin_speaking"
    t.string   "language_mandarin_listening"
    t.string   "language_english_speaking"
    t.string   "language_english_listening"
    t.string   "language_english_writing"
    t.string   "language_other_speaking"
    t.string   "language_other_listening"
    t.string   "language_other_writing"
    t.string   "language_skill"
    t.index ["user_id"], name: "index_language_skills_on_user_id", using: :btree
  end

  create_table "lent_records", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "lent_begin"
    t.datetime "lent_end"
    t.string   "deployment_type"
    t.integer  "original_hall_id"
    t.integer  "temporary_stadium_id"
    t.string   "calculation_of_borrowing"
    t.string   "return_compensation_calculation"
    t.string   "comment"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "valid_date"
    t.datetime "invalid_date"
    t.string   "order_key"
    t.integer  "career_record_id"
    t.index ["career_record_id"], name: "index_lent_records_on_career_record_id", using: :btree
    t.index ["user_id"], name: "index_lent_records_on_user_id", using: :btree
  end

  create_table "lent_temporarily_applies", force: :cascade do |t|
    t.string   "region"
    t.date     "apply_date"
    t.text     "comment"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "salary_calculation"
  end

  create_table "lent_temporarily_items", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "lent_temporarily_apply_id"
    t.date     "lent_date"
    t.date     "return_date"
    t.integer  "lent_location_id"
    t.text     "comment"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "lent_salary_calculation"
    t.string   "return_salary_calculation"
    t.index ["lent_location_id"], name: "index_lent_temporarily_items_on_lent_location_id", using: :btree
    t.index ["lent_temporarily_apply_id"], name: "index_lent_temporarily_items_on_lent_temporarily_apply_id", using: :btree
    t.index ["user_id"], name: "index_lent_temporarily_items_on_user_id", using: :btree
  end

  create_table "location_department_statuses", force: :cascade do |t|
    t.datetime "year_month"
    t.integer  "employees_on_duty"
    t.integer  "employees_left_this_month"
    t.integer  "employees_left_last_day"
    t.integer  "location_id"
    t.integer  "department_id"
    t.integer  "float_salary_month_entry_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["department_id"], name: "index_location_department_statuses_on_department_id", using: :btree
    t.index ["float_salary_month_entry_id"], name: "department_float_salary_month_entry_index", using: :btree
    t.index ["location_id"], name: "index_location_department_statuses_on_location_id", using: :btree
  end

  create_table "location_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "location_anc_desc_idx", unique: true, using: :btree
    t.index ["descendant_id"], name: "location_desc_idx", using: :btree
  end

  create_table "location_statuses", force: :cascade do |t|
    t.datetime "year_month"
    t.integer  "employees_on_duty"
    t.integer  "employees_left_this_month"
    t.integer  "employees_left_last_day"
    t.integer  "location_id"
    t.integer  "float_salary_month_entry_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["float_salary_month_entry_id"], name: "index_location_statuses_on_float_salary_month_entry_id", using: :btree
    t.index ["location_id"], name: "index_location_statuses_on_location_id", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "region_key"
    t.integer  "parent_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "simple_chinese_name"
    t.string   "location_type",       default: "vip_hall"
    t.index ["parent_id"], name: "index_locations_on_parent_id", using: :btree
  end

  create_table "locations_positions", id: false, force: :cascade do |t|
    t.integer "location_id", null: false
    t.integer "position_id", null: false
    t.index ["location_id", "position_id"], name: "index_locations_positions_on_location_id_and_position_id", using: :btree
  end

  create_table "locations_trains", id: false, force: :cascade do |t|
    t.integer "train_id",    null: false
    t.integer "location_id", null: false
    t.index ["train_id", "location_id"], name: "index_locations_trains_on_train_id_and_location_id", using: :btree
  end

  create_table "love_fund_records", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "participate"
    t.datetime "participate_begin"
    t.datetime "participate_end"
    t.integer  "creator_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["creator_id"], name: "index_love_fund_records_on_creator_id", using: :btree
  end

  create_table "love_funds", force: :cascade do |t|
    t.string   "participate"
    t.decimal  "monthly_deduction", precision: 10, scale: 2
    t.integer  "user_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.datetime "participate_date"
    t.datetime "cancel_date"
    t.string   "to_status"
    t.integer  "profile_id"
    t.integer  "operator_id"
    t.index ["monthly_deduction"], name: "index_love_funds_on_monthly_deduction", using: :btree
    t.index ["participate"], name: "index_love_funds_on_participate", using: :btree
    t.index ["profile_id"], name: "index_love_funds_on_profile_id", using: :btree
    t.index ["user_id"], name: "index_love_funds_on_user_id", using: :btree
  end

  create_table "matrix_single_choice_items", force: :cascade do |t|
    t.integer  "matrix_single_choice_question_id"
    t.integer  "item_no"
    t.text     "question"
    t.integer  "score"
    t.boolean  "is_required"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "right_answer"
    t.boolean  "is_filled_in"
    t.index ["matrix_single_choice_question_id"], name: "matrix_single_choice_question_index", using: :btree
  end

  create_table "matrix_single_choice_questions", force: :cascade do |t|
    t.integer  "questionnaire_id"
    t.integer  "questionnaire_template_id"
    t.integer  "order_no"
    t.text     "title"
    t.integer  "max_score"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "value"
    t.integer  "score"
    t.text     "annotation"
    t.decimal  "score_of_question",         precision: 5, scale: 2
    t.index ["questionnaire_id"], name: "index_matrix_single_choice_questions_on_questionnaire_id", using: :btree
    t.index ["questionnaire_template_id"], name: "xxx_questionnaire_template_index", using: :btree
  end

  create_table "medical_informations", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "current_status"
    t.string   "to_status"
    t.datetime "valid_date"
    t.datetime "now_year"
    t.integer  "medical_template_id"
    t.datetime "join_date"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "medical_insurance_participators", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "participate"
    t.datetime "participate_date"
    t.datetime "cancel_date"
    t.decimal  "monthly_deduction", precision: 10, scale: 2
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "to_status"
    t.datetime "valid_date"
    t.integer  "profile_id"
    t.integer  "operator_id"
    t.index ["cancel_date"], name: "index_medical_insurance_participators_on_cancel_date", using: :btree
    t.index ["participate"], name: "index_medical_insurance_participators_on_participate", using: :btree
    t.index ["participate_date"], name: "index_medical_insurance_participators_on_participate_date", using: :btree
    t.index ["user_id"], name: "index_medical_insurance_participators_on_user_id", using: :btree
  end

  create_table "medical_item_templates", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.boolean  "can_be_delete"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "medical_items", force: :cascade do |t|
    t.integer  "reimbursement_times"
    t.decimal  "reimbursement_amount_limit", precision: 10, scale: 2
    t.decimal  "reimbursement_amount",       precision: 10, scale: 2
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "medical_item_template_id"
    t.integer  "medical_template_id"
    t.index ["medical_item_template_id"], name: "index_medical_items_on_medical_item_template_id", using: :btree
    t.index ["medical_template_id"], name: "index_medical_items_on_medical_template_id", using: :btree
    t.index ["reimbursement_amount"], name: "index_medical_items_on_reimbursement_amount", using: :btree
    t.index ["reimbursement_amount_limit"], name: "index_medical_items_on_reimbursement_amount_limit", using: :btree
    t.index ["reimbursement_times"], name: "index_medical_items_on_reimbursement_times", using: :btree
  end

  create_table "medical_items_templates", id: false, force: :cascade do |t|
    t.integer "medical_template_id"
    t.integer "medical_item_id"
    t.index ["medical_item_id"], name: "index_medical_items_templates_on_medical_item_id", using: :btree
    t.index ["medical_template_id"], name: "index_medical_items_templates_on_medical_template_id", using: :btree
  end

  create_table "medical_records", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "participate"
    t.datetime "participate_begin"
    t.datetime "participate_end"
    t.integer  "creator_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["creator_id"], name: "index_medical_records_on_creator_id", using: :btree
  end

  create_table "medical_reimbursements", force: :cascade do |t|
    t.integer  "reimbursement_year"
    t.integer  "user_id"
    t.datetime "apply_date",                                    null: false
    t.integer  "medical_template_id"
    t.integer  "medical_item_id"
    t.string   "document_number",                               null: false
    t.decimal  "document_amount",      precision: 10, scale: 2, null: false
    t.decimal  "reimbursement_amount", precision: 10, scale: 2, null: false
    t.integer  "tracker_id"
    t.datetime "track_date"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.index ["medical_item_id"], name: "index_medical_reimbursements_on_medical_item_id", using: :btree
    t.index ["medical_template_id"], name: "index_medical_reimbursements_on_medical_template_id", using: :btree
    t.index ["tracker_id"], name: "index_medical_reimbursements_on_tracker_id", using: :btree
    t.index ["user_id"], name: "index_medical_reimbursements_on_user_id", using: :btree
  end

  create_table "medical_template_settings", force: :cascade do |t|
    t.jsonb    "sections"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medical_templates", force: :cascade do |t|
    t.string   "chinese_name",              null: false
    t.string   "english_name",              null: false
    t.string   "simple_chinese_name",       null: false
    t.string   "insurance_type",            null: false
    t.datetime "balance_date",              null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "can_be_delete"
    t.boolean  "undestroyable_forever"
    t.boolean  "undestroyable_temporarily"
    t.index ["balance_date"], name: "index_medical_templates_on_balance_date", using: :btree
    t.index ["chinese_name"], name: "index_medical_templates_on_chinese_name", using: :btree
    t.index ["english_name"], name: "index_medical_templates_on_english_name", using: :btree
    t.index ["insurance_type"], name: "index_medical_templates_on_insurance_type", using: :btree
    t.index ["simple_chinese_name"], name: "index_medical_templates_on_simple_chinese_name", using: :btree
  end

  create_table "message_infos", force: :cascade do |t|
    t.string   "content"
    t.string   "target_type"
    t.string   "namespace"
    t.integer  "targets",                  array: true
    t.string   "sender_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "message_statuses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "message_id"
    t.string   "namespace"
    t.boolean  "has_read",   default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "month_salary_attachments", force: :cascade do |t|
    t.string   "status"
    t.string   "file_name"
    t.integer  "attachment_id"
    t.integer  "creator_id"
    t.string   "report_type"
    t.decimal  "download_process", precision: 15, scale: 2
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["attachment_id"], name: "index_month_salary_attachments_on_attachment_id", using: :btree
  end

  create_table "month_salary_change_records", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "original_salary_record_id"
    t.integer  "updated_salary_record_id"
    t.index ["original_salary_record_id"], name: "index_month_salary_change_records_on_original_salary_record_id", using: :btree
    t.index ["updated_salary_record_id"], name: "index_month_salary_change_records_on_updated_salary_record_id", using: :btree
    t.index ["user_id"], name: "index_month_salary_change_records_on_user_id", using: :btree
  end

  create_table "month_salary_reports", force: :cascade do |t|
    t.string   "status"
    t.datetime "year_month"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "salary_type"
    t.decimal  "generate_process", precision: 10, scale: 2
  end

  create_table "museum_records", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "date_of_employment"
    t.string   "deployment_type"
    t.string   "salary_calculation"
    t.integer  "location_id"
    t.string   "comment"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "valid_date"
    t.datetime "invalid_date"
    t.string   "order_key"
    t.integer  "career_record_id"
    t.index ["career_record_id"], name: "index_museum_records_on_career_record_id", using: :btree
    t.index ["user_id"], name: "index_museum_records_on_user_id", using: :btree
  end

  create_table "my_attachments", force: :cascade do |t|
    t.string   "status"
    t.decimal  "download_process", precision: 15, scale: 2, default: "0.0"
    t.string   "file_name"
    t.integer  "attachment_id"
    t.integer  "user_id"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.index ["attachment_id"], name: "index_my_attachments_on_attachment_id", using: :btree
    t.index ["user_id"], name: "index_my_attachments_on_user_id", using: :btree
  end

  create_table "occupation_tax_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "year"
    t.string   "month_1_company"
    t.decimal  "month_1_income_mop",              precision: 15, scale: 2
    t.decimal  "month_1_tax_mop",                 precision: 15, scale: 2
    t.string   "month_2_company"
    t.decimal  "month_2_income_mop",              precision: 15, scale: 2
    t.decimal  "month_2_tax_mop",                 precision: 15, scale: 2
    t.string   "month_3_company"
    t.decimal  "month_3_income_mop",              precision: 15, scale: 2
    t.decimal  "month_3_tax_mop",                 precision: 15, scale: 2
    t.decimal  "quarter_1_income_mop",            precision: 15, scale: 2
    t.decimal  "quarter_1_tax_mop_before_adjust", precision: 15, scale: 2
    t.decimal  "quarter_1_tax_mop_after_adjust",  precision: 15, scale: 2
    t.string   "month_4_company"
    t.decimal  "month_4_income_mop",              precision: 15, scale: 2
    t.decimal  "month_4_tax_mop",                 precision: 15, scale: 2
    t.string   "month_5_company"
    t.decimal  "month_5_income_mop",              precision: 15, scale: 2
    t.decimal  "month_5_tax_mop",                 precision: 15, scale: 2
    t.string   "month_6_company"
    t.decimal  "month_6_income_mop",              precision: 15, scale: 2
    t.decimal  "month_6_tax_mop",                 precision: 15, scale: 2
    t.decimal  "quarter_2_income_mop",            precision: 15, scale: 2
    t.decimal  "quarter_2_tax_mop_before_adjust", precision: 15, scale: 2
    t.decimal  "quarter_2_tax_mop_after_adjust",  precision: 15, scale: 2
    t.string   "month_7_company"
    t.decimal  "month_7_income_mop",              precision: 15, scale: 2
    t.decimal  "month_7_tax_mop",                 precision: 15, scale: 2
    t.string   "month_8_company"
    t.decimal  "month_8_income_mop",              precision: 15, scale: 2
    t.decimal  "month_8_tax_mop",                 precision: 15, scale: 2
    t.string   "month_9_company"
    t.decimal  "month_9_income_mop",              precision: 15, scale: 2
    t.decimal  "month_9_tax_mop",                 precision: 15, scale: 2
    t.decimal  "quarter_3_income_mop",            precision: 15, scale: 2
    t.decimal  "quarter_3_tax_mop_before_adjust", precision: 15, scale: 2
    t.decimal  "quarter_3_tax_mop_after_adjust",  precision: 15, scale: 2
    t.string   "month_10_company"
    t.decimal  "month_10_income_mop",             precision: 15, scale: 2
    t.decimal  "month_10_tax_mop",                precision: 15, scale: 2
    t.string   "month_11_company"
    t.decimal  "month_11_income_mop",             precision: 15, scale: 2
    t.decimal  "month_11_tax_mop",                precision: 15, scale: 2
    t.string   "month_12_company"
    t.decimal  "month_12_income_mop",             precision: 15, scale: 2
    t.decimal  "month_12_tax_mop",                precision: 15, scale: 2
    t.decimal  "quarter_4_income_mop",            precision: 15, scale: 2
    t.decimal  "quarter_4_tax_mop_before_adjust", precision: 15, scale: 2
    t.decimal  "year_income_mop",                 precision: 15, scale: 2
    t.decimal  "year_payable_tax_mop",            precision: 15, scale: 2
    t.decimal  "year_paid_tax_mop",               precision: 15, scale: 2
    t.decimal  "quarter_4_tax_mop_after_adjust",  precision: 15, scale: 2
    t.string   "comment"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.decimal  "double_pay_bonus_and_award",      precision: 15, scale: 2
    t.integer  "department_id"
    t.integer  "position_id"
    t.index ["department_id"], name: "index_occupation_tax_items_on_department_id", using: :btree
    t.index ["position_id"], name: "index_occupation_tax_items_on_position_id", using: :btree
    t.index ["user_id"], name: "index_occupation_tax_items_on_user_id", using: :btree
  end

  create_table "occupation_tax_settings", force: :cascade do |t|
    t.decimal  "deduct_percent",    precision: 10, scale: 2
    t.decimal  "favorable_percent", precision: 10, scale: 2
    t.jsonb    "ranges"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "online_materials", force: :cascade do |t|
    t.string   "name"
    t.string   "file_name"
    t.integer  "creator_id"
    t.string   "instruction"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "attachment_id"
    t.index ["attachable_type", "attachable_id"], name: "index_online_materials_on_attachable_type_and_attachable_id", using: :btree
    t.index ["attachment_id"], name: "index_online_materials_on_attachment_id", using: :btree
    t.index ["creator_id"], name: "index_online_materials_on_creator_id", using: :btree
  end

  create_table "options", force: :cascade do |t|
    t.integer  "choice_question_id"
    t.integer  "option_no"
    t.string   "description"
    t.string   "supplement"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.boolean  "has_supplement"
    t.index ["choice_question_id"], name: "index_options_on_choice_question_id", using: :btree
  end

  create_table "over_time_items", force: :cascade do |t|
    t.integer  "over_time_id"
    t.integer  "over_time_type"
    t.integer  "make_up_type"
    t.string   "from"
    t.string   "to"
    t.float    "duration"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "comment"
    t.datetime "to_date"
    t.date     "date"
    t.string   "shift_info"
    t.string   "work_time"
    t.string   "come"
    t.string   "leave"
    t.index ["over_time_id"], name: "index_over_time_items_on_over_time_id", using: :btree
  end

  create_table "over_times", force: :cascade do |t|
    t.date     "date"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "status",      default: 1,           null: false
    t.integer  "item_count"
    t.text     "comment"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "record_type", default: "over_time", null: false
    t.index ["creator_id"], name: "index_over_times_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_over_times_on_user_id", using: :btree
  end

  create_table "overtime_records", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.boolean  "is_compensate"
    t.integer  "overtime_type"
    t.integer  "compensate_type"
    t.date     "overtime_start_date"
    t.date     "overtime_end_date"
    t.datetime "overtime_start_time"
    t.datetime "overtime_end_time"
    t.integer  "overtime_hours"
    t.integer  "vehicle_department_over_time_min"
    t.text     "comment"
    t.boolean  "is_deleted"
    t.integer  "creator_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "source_id"
    t.date     "overtime_true_start_date"
    t.date     "input_date"
    t.string   "input_time"
    t.index ["creator_id"], name: "index_overtime_records_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_overtime_records_on_user_id", using: :btree
  end

  create_table "paid_sick_leave_awards", force: :cascade do |t|
    t.string   "award_chinese_name",             null: false
    t.string   "award_english_name",             null: false
    t.string   "begin_date",                     null: false
    t.string   "end_date",                       null: false
    t.string   "due_date",                       null: false
    t.integer  "has_offered",        default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "paid_sick_leave_report_items", force: :cascade do |t|
    t.integer  "paid_sick_leave_report_id"
    t.integer  "year"
    t.integer  "department_id"
    t.integer  "user_id"
    t.date     "entry_date"
    t.integer  "on_duty_days"
    t.integer  "paid_sick_leave_counts"
    t.integer  "obtain_counts"
    t.boolean  "is_release"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.date     "valid_period"
    t.index ["paid_sick_leave_report_id"], name: "index_paid_sick_leave_report_items_on_paid_sick_leave_report_id", using: :btree
    t.index ["user_id"], name: "index_paid_sick_leave_report_items_on_user_id", using: :btree
  end

  create_table "paid_sick_leave_reports", force: :cascade do |t|
    t.integer  "year"
    t.date     "valid_period"
    t.boolean  "is_release"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "pass_entry_trials", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.date     "apply_date"
    t.text     "employee_advantage"
    t.text     "employee_need_to_improve"
    t.text     "employee_opinion"
    t.boolean  "result"
    t.date     "trial_expiration_date"
    t.boolean  "dismissal"
    t.date     "last_working_date"
    t.text     "comment"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.jsonb    "salary_record"
    t.jsonb    "new_salary_record"
    t.string   "salary_calculation"
    t.index ["user_id"], name: "index_pass_entry_trials_on_user_id", using: :btree
  end

  create_table "pass_trials", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.date     "apply_date"
    t.text     "employee_advantage"
    t.text     "employee_need_to_improve"
    t.text     "employee_opinion"
    t.boolean  "result"
    t.date     "trial_expiration_date"
    t.boolean  "dismissal"
    t.date     "last_working_date"
    t.text     "comment"
    t.integer  "trial_type"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.jsonb    "salary_record"
    t.jsonb    "new_salary_record"
    t.string   "salary_calculation"
    t.index ["user_id"], name: "index_pass_trials_on_user_id", using: :btree
  end

  create_table "pay_slips", force: :cascade do |t|
    t.datetime "year_month"
    t.datetime "salary_begin"
    t.datetime "salary_end"
    t.integer  "user_id"
    t.boolean  "entry_on_this_month"
    t.boolean  "leave_on_this_month"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "comment"
    t.string   "salary_type"
    t.integer  "resignation_record_id"
    t.index ["user_id"], name: "index_pay_slips_on_user_id", using: :btree
  end

  create_table "payroll_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "year_month"
    t.string   "check_or_cash"
    t.decimal  "social_security_fund_reduction_mop",         precision: 15, scale: 2
    t.decimal  "actual_amount_mop",                          precision: 15, scale: 2
    t.decimal  "actual_amount_hkd",                          precision: 15, scale: 2
    t.decimal  "total_amount_mop",                           precision: 15, scale: 2
    t.decimal  "base_salary_mop",                            precision: 15, scale: 2
    t.decimal  "overtime_pay_mop",                           precision: 15, scale: 2
    t.decimal  "compulsion_holiday_compensation_mop",        precision: 15, scale: 2
    t.decimal  "public_holiday_compensation_mop",            precision: 15, scale: 2
    t.decimal  "medicare_reimbursement_mop",                 precision: 15, scale: 2
    t.decimal  "vip_card_consumption_mop",                   precision: 15, scale: 2
    t.decimal  "paid_maternity_compensation_mop",            precision: 15, scale: 2
    t.decimal  "double_pay_mop",                             precision: 15, scale: 2
    t.decimal  "year_end_bonus_mop",                         precision: 15, scale: 2
    t.decimal  "seniority_compensation_mop",                 precision: 15, scale: 2
    t.decimal  "dismission_annual_holiday_compensation_mop", precision: 15, scale: 2
    t.decimal  "dismission_inform_period_compensation_mop",  precision: 15, scale: 2
    t.decimal  "total_reduction_mop",                        precision: 15, scale: 2
    t.decimal  "medical_insurance_plan_reduction_mop",       precision: 15, scale: 2
    t.decimal  "public_accumulation_fund_reduction_mop",     precision: 15, scale: 2
    t.decimal  "love_fund_reduction_mop",                    precision: 15, scale: 2
    t.decimal  "absenteeism_reduction_mop",                  precision: 15, scale: 2
    t.decimal  "immediate_leave_reduction_mop",              precision: 15, scale: 2
    t.decimal  "unpaid_leave_reduction_mop",                 precision: 15, scale: 2
    t.decimal  "unpaid_marriage_leave_reduction_mop",        precision: 15, scale: 2
    t.decimal  "unpaid_compassionate_leave_reduction_mop",   precision: 15, scale: 2
    t.decimal  "unpaid_maternity_leave_reduction_mop",       precision: 15, scale: 2
    t.decimal  "pregnant_sick_leave_reduction_mop",          precision: 15, scale: 2
    t.decimal  "occupational_injury_reduction_mop",          precision: 15, scale: 2
    t.decimal  "total_salary_hkd",                           precision: 15, scale: 2
    t.decimal  "benefits_hkd",                               precision: 15, scale: 2
    t.decimal  "incentive_hkd",                              precision: 15, scale: 2
    t.decimal  "housing_benefit_hkd",                        precision: 15, scale: 2
    t.decimal  "cover_charge_hkd",                           precision: 15, scale: 2
    t.decimal  "kill_bonus_hkd",                             precision: 15, scale: 2
    t.decimal  "performance_bonus_hkd",                      precision: 15, scale: 2
    t.decimal  "swiping_card_bonus_hkd",                     precision: 15, scale: 2
    t.decimal  "commission_margin_hkd",                      precision: 15, scale: 2
    t.decimal  "collect_accounts_bonus_hkd",                 precision: 15, scale: 2
    t.decimal  "exchange_rate_bonus_hkd",                    precision: 15, scale: 2
    t.decimal  "zunhuadian_hkd",                             precision: 15, scale: 2
    t.decimal  "xinchunlishi_hkd",                           precision: 15, scale: 2
    t.decimal  "project_bonus_hkd",                          precision: 15, scale: 2
    t.decimal  "shangpin_bonus_hkd",                         precision: 15, scale: 2
    t.decimal  "dispatch_bonus_hkd",                         precision: 15, scale: 2
    t.decimal  "recommand_new_guest_bonus_hkd",              precision: 15, scale: 2
    t.decimal  "typhoon_benefits_hkd",                       precision: 15, scale: 2
    t.decimal  "annual_incentive_payment_hkd",               precision: 15, scale: 2
    t.decimal  "back_pay_hkd",                               precision: 15, scale: 2
    t.decimal  "total_reduction_hkd",                        precision: 15, scale: 2
    t.decimal  "absenteeism_reduction_hkd",                  precision: 15, scale: 2
    t.decimal  "immediate_leave_reduction_hkd",              precision: 15, scale: 2
    t.decimal  "unpaid_leave_reduction_hkd",                 precision: 15, scale: 2
    t.decimal  "unpaid_marriage_leave_reduction_hkd",        precision: 15, scale: 2
    t.decimal  "unpaid_compassionate_leave_reduction_hkd",   precision: 15, scale: 2
    t.decimal  "unpaid_maternity_leave_reduction_hkd",       precision: 15, scale: 2
    t.decimal  "pregnant_sick_leave_reduction_hkd",          precision: 15, scale: 2
    t.decimal  "occupational_injury_reduction_hkd",          precision: 15, scale: 2
    t.decimal  "paid_sick_leave_reduction_hkd",              precision: 15, scale: 2
    t.decimal  "late_reduction_hkd",                         precision: 15, scale: 2
    t.decimal  "missing_punch_card_reduction_hkd",           precision: 15, scale: 2
    t.decimal  "punishment_reduction_hkd",                   precision: 15, scale: 2
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "payroll_report_id"
    t.index ["payroll_report_id"], name: "index_payroll_items_on_payroll_report_id", using: :btree
    t.index ["user_id"], name: "index_payroll_items_on_user_id", using: :btree
  end

  create_table "payroll_reports", force: :cascade do |t|
    t.datetime "year_month"
    t.boolean  "granted",    default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "status",     default: "initial"
  end

  create_table "performance_interviews", force: :cascade do |t|
    t.integer  "appraisal_id"
    t.integer  "appraisal_participator_id"
    t.datetime "interview_date"
    t.datetime "interview_time_begin"
    t.datetime "interview_time_end"
    t.datetime "operator_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "performance_moderator_id"
    t.integer  "operator_id"
    t.string   "performance_interview_status"
    t.index ["appraisal_id"], name: "index_performance_interviews_on_appraisal_id", using: :btree
    t.index ["appraisal_participator_id"], name: "index_performance_interviews_on_appraisal_participator_id", using: :btree
    t.index ["operator_id"], name: "index_performance_interviews_on_operator_id", using: :btree
    t.index ["performance_moderator_id"], name: "index_performance_interviews_on_performance_moderator_id", using: :btree
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "resource"
    t.string   "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "region"
    t.index ["region"], name: "index_permissions_on_region", using: :btree
  end

  create_table "permissions_roles", id: false, force: :cascade do |t|
    t.integer "role_id",       null: false
    t.integer "permission_id", null: false
    t.index ["permission_id", "role_id"], name: "index_permissions_roles_on_permission_id_and_role_id", using: :btree
    t.index ["role_id", "permission_id"], name: "index_permissions_roles_on_role_id_and_permission_id", using: :btree
  end

  create_table "position_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "position_anc_desc_idx", unique: true, using: :btree
    t.index ["descendant_id"], name: "position_desc_idx", using: :btree
  end

  create_table "positions", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "number"
    t.string   "grade"
    t.text     "comment"
    t.string   "region_key"
    t.integer  "parent_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "status",              default: 0
    t.string   "simple_chinese_name"
    t.index ["parent_id"], name: "index_positions_on_parent_id", using: :btree
  end

  create_table "positions_trains", id: false, force: :cascade do |t|
    t.integer "train_id",    null: false
    t.integer "position_id", null: false
    t.index ["train_id", "position_id"], name: "index_positions_trains_on_train_id_and_position_id", using: :btree
  end

  create_table "professional_qualifications", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "professional_certificate"
    t.string   "orgnaization"
    t.datetime "issue_date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["profile_id"], name: "index_professional_qualifications_on_profile_id", using: :btree
  end

  create_table "profile_attachments", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "profile_attachment_type_id"
    t.integer  "attachment_id"
    t.text     "description"
    t.integer  "creator_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "file_name"
    t.index ["attachment_id"], name: "index_profile_attachments_on_attachment_id", using: :btree
    t.index ["creator_id"], name: "index_profile_attachments_on_creator_id", using: :btree
    t.index ["profile_attachment_type_id"], name: "index_profile_attachments_on_profile_attachment_type_id", using: :btree
    t.index ["profile_id"], name: "index_profile_attachments_on_profile_id", using: :btree
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "region"
    t.jsonb    "data"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.jsonb    "filled_attachment_types"
    t.boolean  "attachment_missing_sms_sent", default: false
    t.boolean  "is_stashed",                  default: false
    t.integer  "current_welfare_template_id"
    t.integer  "current_template_type"
    t.boolean  "welfare_template_effected"
    t.index ["region"], name: "index_profiles_on_region", using: :btree
    t.index ["user_id"], name: "index_profiles_on_user_id", using: :btree
  end

  create_table "profit_conflict_informations", force: :cascade do |t|
    t.boolean  "have_or_no"
    t.string   "number"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profit_conflict_informations_on_user_id", using: :btree
  end

  create_table "provident_fund_member_report_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_provident_fund_member_report_items_on_user_id", using: :btree
  end

  create_table "provident_funds", force: :cascade do |t|
    t.string   "member_retirement_fund_number"
    t.string   "tax_registration"
    t.string   "icbc_account_number_mop"
    t.string   "icbc_account_number_rmb"
    t.boolean  "is_an_american"
    t.boolean  "has_permanent_resident_certificate"
    t.string   "supplier"
    t.decimal  "steady_growth_fund_percentage",      precision: 15, scale: 2
    t.decimal  "steady_fund_percentage",             precision: 15, scale: 2
    t.decimal  "a_fund_percentage",                  precision: 15, scale: 2
    t.decimal  "b_fund_percentage",                  precision: 15, scale: 2
    t.integer  "profile_id"
    t.integer  "first_beneficiary_id"
    t.integer  "second_beneficiary_id"
    t.integer  "third_beneficiary_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "provident_fund_resignation_reason"
    t.integer  "user_id"
    t.datetime "participation_date"
    t.datetime "provident_fund_resignation_date"
    t.index ["first_beneficiary_id"], name: "index_provident_funds_on_first_beneficiary_id", using: :btree
    t.index ["profile_id"], name: "index_provident_funds_on_profile_id", using: :btree
    t.index ["second_beneficiary_id"], name: "index_provident_funds_on_second_beneficiary_id", using: :btree
    t.index ["third_beneficiary_id"], name: "index_provident_funds_on_third_beneficiary_id", using: :btree
    t.index ["user_id"], name: "index_provident_funds_on_user_id", using: :btree
  end

  create_table "public_holidays", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.integer  "category"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "comment"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "punch_card_states", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "profile_id"
    t.boolean  "is_need"
    t.boolean  "is_effective"
    t.date     "effective_date"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "creator_id"
    t.integer  "source_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "is_current"
    t.index ["creator_id"], name: "index_punch_card_states_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_punch_card_states_on_user_id", using: :btree
  end

  create_table "punishments", force: :cascade do |t|
    t.string   "punishment_category"
    t.string   "punishment_content"
    t.string   "punishment_result"
    t.string   "punishment_remarks"
    t.integer  "user_id"
    t.boolean  "incident_customer_involved"
    t.boolean  "incident_employee_involved"
    t.boolean  "incident_casino_involved"
    t.boolean  "incident_thirdparty_involved"
    t.boolean  "incident_suspended"
    t.boolean  "target_response_title"
    t.string   "target_response_content"
    t.datetime "target_response_datetime_from"
    t.datetime "target_response_datetime_to"
    t.boolean  "reinstated"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.datetime "punishment_date"
    t.datetime "incident_suspended_date"
    t.datetime "reinstated_date"
    t.decimal  "incident_money_involved",       precision: 10, scale: 2
    t.datetime "track_date"
    t.integer  "tracker_id"
    t.string   "punishment_status"
    t.datetime "incident_time_from"
    t.datetime "incident_time_to"
    t.string   "incident_place"
    t.string   "incident_discoverer"
    t.string   "incident_discoverer_phone"
    t.string   "incident_handler"
    t.string   "incident_handler_phone"
    t.string   "incident_description"
    t.boolean  "incident_financial_influence"
    t.string   "records_in_where"
    t.integer  "profile_validity_period"
    t.integer  "profile_penalty_score"
    t.datetime "profile_abolition_date"
    t.string   "profile_punishment_status"
    t.string   "profile_remarks"
    t.boolean  "salary_deduct_status",                                   default: false
    t.boolean  "is_poor_attendance"
    t.index ["punishment_category"], name: "index_punishments_on_punishment_category", using: :btree
    t.index ["punishment_result"], name: "index_punishments_on_punishment_result", using: :btree
    t.index ["tracker_id"], name: "index_punishments_on_tracker_id", using: :btree
    t.index ["user_id"], name: "index_punishments_on_user_id", using: :btree
  end

  create_table "questionnaire_templates", force: :cascade do |t|
    t.string   "region"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "template_type"
    t.text     "template_introduction"
    t.integer  "questionnaires_count",  default: 0
    t.integer  "creator_id"
    t.text     "comment"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["creator_id"], name: "index_questionnaire_templates_on_creator_id", using: :btree
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string   "region"
    t.integer  "questionnaire_template_id"
    t.integer  "user_id"
    t.boolean  "is_filled_in"
    t.date     "release_date"
    t.integer  "release_user_id"
    t.date     "submit_date"
    t.text     "comment"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["questionnaire_template_id"], name: "index_questionnaires_on_questionnaire_template_id", using: :btree
    t.index ["release_user_id"], name: "index_questionnaires_on_release_user_id", using: :btree
    t.index ["user_id"], name: "index_questionnaires_on_user_id", using: :btree
  end

  create_table "regions", primary_key: "key", id: :string, force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "report_columns", force: :cascade do |t|
    t.integer  "report_id"
    t.string   "key"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "value_type"
    t.string   "data_index"
    t.string   "search_type"
    t.boolean  "sorter"
    t.string   "options_type"
    t.jsonb    "options_predefined"
    t.string   "options_endpoint"
    t.string   "source_data_type"
    t.string   "source_model"
    t.string   "source_model_user_association_attribute"
    t.string   "join_attribute"
    t.string   "source_attribute"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "user_source_model_association_attribute"
    t.string   "option_attribute"
    t.string   "value_format"
    t.index ["report_id"], name: "index_report_columns_on_report_id", using: :btree
  end

  create_table "reports", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "key"
    t.string   "url_type"
    t.string   "rows_url"
    t.string   "columns_url"
    t.string   "options_url"
  end

  create_table "reserved_holiday_participators", force: :cascade do |t|
    t.integer  "reserved_holiday_setting_id"
    t.integer  "user_id"
    t.integer  "owned_days_count"
    t.integer  "taken_days_count"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["reserved_holiday_setting_id"], name: "index_participators_on_reserved_holiday_setting_id", using: :btree
    t.index ["user_id"], name: "index_reserved_holiday_participators_on_user_id", using: :btree
  end

  create_table "reserved_holiday_settings", force: :cascade do |t|
    t.boolean  "can_destroy"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.datetime "date_begin"
    t.datetime "date_end"
    t.integer  "days_count"
    t.integer  "member_count"
    t.text     "comment"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "creator_id"
    t.datetime "update_date"
    t.index ["creator_id"], name: "index_reserved_holiday_settings_on_creator_id", using: :btree
  end

  create_table "resignation_records", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "status"
    t.string   "time_arrive"
    t.datetime "resigned_date"
    t.string   "resigned_reason"
    t.string   "reason_for_resignation"
    t.string   "employment_status"
    t.integer  "department_id"
    t.integer  "position_id"
    t.string   "comment"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "compensation_year"
    t.boolean  "notice_period_compensation"
    t.datetime "valid_date"
    t.datetime "invalid_date"
    t.string   "order_key"
    t.datetime "notice_date"
    t.datetime "final_work_date"
    t.boolean  "is_in_whitelist",            default: true
    t.index ["user_id"], name: "index_resignation_records_on_user_id", using: :btree
  end

  create_table "revise_clock_assistants", force: :cascade do |t|
    t.integer  "revise_clock_item_id"
    t.string   "sign_time"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["revise_clock_item_id"], name: "index_revise_clock_assistants_on_revise_clock_item_id", using: :btree
  end

  create_table "revise_clock_items", force: :cascade do |t|
    t.integer  "revise_clock_id"
    t.date     "clock_date"
    t.datetime "clock_in_time"
    t.datetime "clock_out_time"
    t.jsonb    "attendance_state"
    t.datetime "new_clock_in_time"
    t.datetime "new_clock_out_time"
    t.jsonb    "new_attendance_state"
    t.text     "comment"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "user_id"
    t.index ["revise_clock_id"], name: "index_revise_clock_items_on_revise_clock_id", using: :btree
    t.index ["user_id"], name: "index_revise_clock_items_on_user_id", using: :btree
  end

  create_table "revise_clocks", force: :cascade do |t|
    t.date     "date"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "status",      default: 1,              null: false
    t.integer  "item_count"
    t.text     "comment"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "record_type", default: "revise_clock", null: false
    t.index ["creator_id"], name: "index_revise_clocks_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_revise_clocks_on_user_id", using: :btree
  end

  create_table "revision_histories", force: :cascade do |t|
    t.integer  "appraisal_questionnaire_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "revision_date"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["appraisal_questionnaire_id"], name: "index_revision_histories_on_appraisal_questionnaire_id", using: :btree
    t.index ["user_id"], name: "index_revision_histories_on_user_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "key"
    t.boolean  "fixed"
    t.string   "simple_chinese_name"
    t.string   "introduction_chinese_name"
    t.string   "introduction_english_name"
    t.string   "introduction_simple_chinese_name"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", using: :btree
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", using: :btree
  end

  create_table "roster_instructions", force: :cascade do |t|
    t.string   "comment"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_roster_instructions_on_user_id", using: :btree
  end

  create_table "roster_interval_preferences", force: :cascade do |t|
    t.integer  "roster_preference_id"
    t.integer  "position_id"
    t.integer  "interval_hours"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["roster_preference_id"], name: "index_roster_interval_preferences_on_roster_preference_id", using: :btree
  end

  create_table "roster_item_logs", force: :cascade do |t|
    t.integer  "roster_item_id"
    t.integer  "user_id"
    t.datetime "log_time"
    t.string   "log_type"
    t.integer  "log_type_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["roster_item_id"], name: "index_roster_item_logs_on_roster_item_id", using: :btree
    t.index ["user_id"], name: "index_roster_item_logs_on_user_id", using: :btree
  end

  create_table "roster_items", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "shift_id"
    t.integer  "roster_id"
    t.date     "date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "leave_type"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "state",       default: 0
    t.boolean  "is_modified"
    t.boolean  "uneditable"
    t.index ["roster_id"], name: "index_roster_items_on_roster_id", using: :btree
    t.index ["shift_id"], name: "index_roster_items_on_shift_id", using: :btree
    t.index ["user_id"], name: "index_roster_items_on_user_id", using: :btree
  end

  create_table "roster_lists", force: :cascade do |t|
    t.string   "region"
    t.integer  "status"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.integer  "location_id"
    t.integer  "department_id"
    t.string   "date_range"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "employment_counts"
    t.integer  "roster_counts"
    t.integer  "general_holiday_counts"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "calc_state"
    t.index ["department_id"], name: "index_roster_lists_on_department_id", using: :btree
    t.index ["location_id"], name: "index_roster_lists_on_location_id", using: :btree
  end

  create_table "roster_model_states", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "profile_id"
    t.integer  "roster_model_id"
    t.boolean  "is_effective"
    t.date     "effective_date"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "start_week_no"
    t.integer  "current_week_no"
    t.integer  "source_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "is_current"
    t.index ["roster_model_id"], name: "index_roster_model_states_on_roster_model_id", using: :btree
    t.index ["user_id"], name: "index_roster_model_states_on_user_id", using: :btree
  end

  create_table "roster_model_weeks", force: :cascade do |t|
    t.string   "region"
    t.integer  "roster_model_id"
    t.integer  "order_no"
    t.integer  "mon_class_setting_id"
    t.integer  "tue_class_setting_id"
    t.integer  "wed_class_setting_id"
    t.integer  "thu_class_setting_id"
    t.integer  "fri_class_setting_id"
    t.integer  "sat_class_setting_id"
    t.integer  "sun_class_setting_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["roster_model_id"], name: "index_roster_model_weeks_on_roster_model_id", using: :btree
  end

  create_table "roster_models", force: :cascade do |t|
    t.string   "region"
    t.string   "chinese_name"
    t.integer  "department_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "weeks_count"
    t.boolean  "be_used"
    t.integer  "be_user_count"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["department_id"], name: "index_roster_models_on_department_id", using: :btree
  end

  create_table "roster_object_logs", force: :cascade do |t|
    t.integer  "approver_id"
    t.datetime "approval_time"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "roster_object_id"
    t.integer  "class_setting_id"
    t.boolean  "is_general_holiday"
    t.string   "working_time"
    t.string   "modified_reason"
    t.string   "holiday_type"
    t.string   "borrow_return_type"
    t.integer  "working_hours_transaction_record_id"
    t.index ["approver_id"], name: "index_roster_object_logs_on_approver_id", using: :btree
    t.index ["class_setting_id"], name: "index_roster_object_logs_on_class_setting_id", using: :btree
    t.index ["roster_object_id"], name: "index_roster_object_logs_on_roster_object_id", using: :btree
    t.index ["working_hours_transaction_record_id"], name: "index_roster_object_logs_on_working_hours_transaction_record_id", using: :btree
  end

  create_table "roster_objects", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "location_id"
    t.integer  "department_id"
    t.date     "roster_date"
    t.integer  "roster_list_id"
    t.integer  "class_setting_id"
    t.boolean  "is_general_holiday"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "working_time"
    t.string   "holiday_type"
    t.integer  "special_type"
    t.integer  "is_active"
    t.integer  "holiday_record_id"
    t.integer  "working_hours_transaction_record_id"
    t.string   "borrow_return_type"
    t.string   "adjust_type"
    t.boolean  "change_to_general_holiday"
    t.index ["class_setting_id"], name: "index_roster_objects_on_class_setting_id", using: :btree
    t.index ["department_id"], name: "index_roster_objects_on_department_id", using: :btree
    t.index ["holiday_record_id"], name: "index_roster_objects_on_holiday_record_id", using: :btree
    t.index ["location_id"], name: "index_roster_objects_on_location_id", using: :btree
    t.index ["roster_list_id"], name: "index_roster_objects_on_roster_list_id", using: :btree
    t.index ["user_id"], name: "index_roster_objects_on_user_id", using: :btree
    t.index ["working_hours_transaction_record_id"], name: "index_roster_objects_on_working_hours_transaction_record_id", using: :btree
  end

  create_table "roster_preferences", force: :cascade do |t|
    t.integer  "roster_list_id"
    t.integer  "location_id"
    t.integer  "department_id"
    t.integer  "latest_updater_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["department_id"], name: "index_roster_preferences_on_department_id", using: :btree
    t.index ["latest_updater_id"], name: "index_roster_preferences_on_latest_updater_id", using: :btree
    t.index ["location_id"], name: "index_roster_preferences_on_location_id", using: :btree
  end

  create_table "roster_settings", force: :cascade do |t|
    t.integer  "roster_id"
    t.jsonb    "shift_interval_hour"
    t.jsonb    "rest_number"
    t.jsonb    "rest_interval_day"
    t.jsonb    "shift_type_number"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["roster_id"], name: "index_roster_settings_on_roster_id", using: :btree
  end

  create_table "rosters", force: :cascade do |t|
    t.integer  "department_id"
    t.string   "state"
    t.string   "region"
    t.jsonb    "shift_interval"
    t.jsonb    "rest_day_amount_per_week"
    t.jsonb    "rest_day_interval"
    t.jsonb    "in_between_rest_day_shift_type_amount"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "snapshot_employees_count"
    t.integer  "location_id"
    t.date     "from"
    t.date     "to"
    t.jsonb    "condition"
    t.index ["department_id"], name: "index_rosters_on_department_id", using: :btree
    t.index ["location_id"], name: "index_rosters_on_location_id", using: :btree
    t.index ["region"], name: "index_rosters_on_region", using: :btree
  end

  create_table "salary_column_templates", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "default"
    t.integer  "original_column_order", default: [],              array: true
  end

  create_table "salary_column_templates_columns", id: false, force: :cascade do |t|
    t.integer "salary_column_id",          null: false
    t.integer "salary_column_template_id", null: false
    t.index ["salary_column_id", "salary_column_template_id"], name: "index_on_join_table_sc_sct", using: :btree
  end

  create_table "salary_columns", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "column_type"
    t.string   "function"
    t.string   "add_deduct_type"
    t.string   "tax_type"
    t.string   "value_type"
    t.string   "category"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "order_no"
  end

  create_table "salary_element_categories", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "key"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "salary_element_factors", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "key"
    t.integer  "salary_element_id"
    t.string   "factor_type"
    t.decimal  "numerator",           precision: 10, scale: 2
    t.decimal  "denominator",         precision: 10, scale: 2
    t.decimal  "value",               precision: 10, scale: 2
    t.string   "comment"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.index ["salary_element_id"], name: "index_salary_element_factors_on_salary_element_id", using: :btree
  end

  create_table "salary_elements", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "key"
    t.integer  "salary_element_category_id"
    t.string   "display_template"
    t.string   "comment"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["salary_element_category_id"], name: "index_salary_elements_on_salary_element_category_id", using: :btree
  end

  create_table "salary_records", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "change_reason"
    t.datetime "salary_begin"
    t.datetime "salary_end"
    t.integer  "salary_template_id"
    t.decimal  "basic_salary",        precision: 10, scale: 2, default: "0.0"
    t.decimal  "bonus",               precision: 10, scale: 2, default: "0.0"
    t.decimal  "attendance_award",    precision: 10, scale: 2, default: "0.0"
    t.decimal  "new_year_bonus",      precision: 10, scale: 2, default: "0.0"
    t.decimal  "project_bonus",       precision: 10, scale: 2, default: "0.0"
    t.decimal  "product_bonus",       precision: 10, scale: 2, default: "0.0"
    t.decimal  "tea_bonus",           precision: 10, scale: 2, default: "0.0"
    t.decimal  "kill_bonus",          precision: 10, scale: 2, default: "0.0"
    t.decimal  "performance_bonus",   precision: 10, scale: 2, default: "0.0"
    t.decimal  "charge_bonus",        precision: 10, scale: 2, default: "0.0"
    t.decimal  "commission_bonus",    precision: 10, scale: 2, default: "0.0"
    t.decimal  "receive_bonus",       precision: 10, scale: 2, default: "0.0"
    t.decimal  "exchange_rate_bonus", precision: 10, scale: 2, default: "0.0"
    t.decimal  "guest_card_bonus",    precision: 10, scale: 2, default: "0.0"
    t.decimal  "respect_bonus",       precision: 10, scale: 2, default: "0.0"
    t.string   "comment"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.decimal  "region_bonus",        precision: 10, scale: 2, default: "0.0"
    t.datetime "valid_date"
    t.datetime "invalid_date"
    t.string   "order_key"
    t.decimal  "house_bonus",         precision: 15, scale: 2, default: "0.0"
    t.decimal  "service_award",       precision: 15, scale: 2
    t.decimal  "internship_bonus",    precision: 15, scale: 2
    t.decimal  "performance_award",   precision: 15, scale: 2
    t.decimal  "special_tie_bonus",   precision: 15, scale: 2
    t.index ["invalid_date"], name: "index_salary_records_on_invalid_date", using: :btree
    t.index ["salary_begin"], name: "index_salary_records_on_salary_begin", using: :btree
    t.index ["salary_end"], name: "index_salary_records_on_salary_end", using: :btree
    t.index ["salary_template_id"], name: "index_salary_records_on_salary_template_id", using: :btree
    t.index ["user_id"], name: "index_salary_records_on_user_id", using: :btree
    t.index ["valid_date"], name: "index_salary_records_on_valid_date", using: :btree
  end

  create_table "salary_templates", force: :cascade do |t|
    t.string   "template_chinese_name"
    t.string   "template_english_name"
    t.string   "template_simple_chinese_name"
    t.jsonb    "belongs_to",                                            default: {}
    t.string   "comment"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.decimal  "new_year_bonus",               precision: 15, scale: 2
    t.decimal  "project_bonus",                precision: 15, scale: 2
    t.decimal  "product_bonus",                precision: 15, scale: 2
    t.decimal  "tea_bonus",                    precision: 15, scale: 2
    t.decimal  "kill_bonus",                   precision: 15, scale: 2
    t.decimal  "performance_bonus",            precision: 15, scale: 2
    t.decimal  "charge_bonus",                 precision: 15, scale: 2
    t.decimal  "commission_bonus",             precision: 15, scale: 2
    t.decimal  "receive_bonus",                precision: 15, scale: 2
    t.decimal  "exchange_rate_bonus",          precision: 15, scale: 2
    t.decimal  "guest_card_bonus",             precision: 15, scale: 2
    t.decimal  "respect_bonus",                precision: 15, scale: 2
    t.decimal  "region_bonus",                 precision: 15, scale: 2
    t.decimal  "basic_salary",                 precision: 15, scale: 2
    t.decimal  "bonus",                        precision: 15, scale: 2
    t.decimal  "attendance_award",             precision: 15, scale: 2
    t.decimal  "house_bonus",                  precision: 15, scale: 2
    t.decimal  "service_award",                precision: 15, scale: 2
    t.decimal  "internship_bonus",             precision: 15, scale: 2
    t.decimal  "performance_award",            precision: 15, scale: 2
    t.decimal  "special_tie_bonus",            precision: 15, scale: 2
  end

  create_table "salary_values", force: :cascade do |t|
    t.string   "string_value"
    t.integer  "integer_value"
    t.datetime "date_value"
    t.integer  "user_id"
    t.jsonb    "object_value"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "salary_column_id"
    t.datetime "year_month"
    t.string   "salary_type"
    t.boolean  "boolean_value"
    t.integer  "resignation_record_id"
    t.decimal  "decimal_value",         precision: 30, scale: 4
    t.index ["resignation_record_id"], name: "index_salary_values_on_resignation_record_id", using: :btree
    t.index ["salary_column_id"], name: "index_salary_values_on_salary_column_id", using: :btree
    t.index ["user_id"], name: "index_salary_values_on_user_id", using: :btree
  end

  create_table "select_column_templates", force: :cascade do |t|
    t.string   "name"
    t.jsonb    "select_column_keys"
    t.boolean  "default",            default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "region"
    t.integer  "department_id"
    t.string   "attachType"
    t.index ["default"], name: "index_select_column_templates_on_default", using: :btree
    t.index ["department_id"], name: "index_select_column_templates_on_department_id", using: :btree
  end

  create_table "shift_employee_count_settings", force: :cascade do |t|
    t.integer  "grade_tag"
    t.integer  "max_number"
    t.integer  "min_number"
    t.date     "date"
    t.integer  "shift_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "roster_id"
    t.index ["roster_id"], name: "index_shift_employee_count_settings_on_roster_id", using: :btree
    t.index ["shift_id"], name: "index_shift_employee_count_settings_on_shift_id", using: :btree
  end

  create_table "shift_groups", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.text     "comment"
    t.jsonb    "member_user_ids"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "roster_id"
    t.boolean  "is_together",     default: true
    t.index ["roster_id"], name: "index_shift_groups_on_roster_id", using: :btree
  end

  create_table "shift_states", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "current_is_shift",      default: true
    t.string   "current_working_hour"
    t.boolean  "future_is_shift"
    t.string   "future_working_hour"
    t.datetime "future_affective_date"
    t.index ["user_id"], name: "index_shift_states_on_user_id", using: :btree
  end

  create_table "shift_statuses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "profile_id"
    t.boolean  "is_shift"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_shift_statuses_on_user_id", using: :btree
  end

  create_table "shift_user_settings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "roster_id"
    t.jsonb    "shift_interval"
    t.jsonb    "shift_special"
    t.jsonb    "rest_interval"
    t.jsonb    "rest_special"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["roster_id"], name: "index_shift_user_settings_on_roster_id", using: :btree
    t.index ["user_id"], name: "index_shift_user_settings_on_user_id", using: :btree
  end

  create_table "shifts", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "start_time"
    t.string   "end_time"
    t.integer  "time_length"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "roster_id"
    t.string   "english_name"
    t.integer  "allow_be_late_minute"
    t.integer  "allow_leave_early_minute"
    t.boolean  "is_next"
    t.index ["roster_id"], name: "index_shifts_on_roster_id", using: :btree
  end

  create_table "sign_card_reasons", force: :cascade do |t|
    t.string   "region"
    t.integer  "sign_card_setting_id"
    t.string   "reason"
    t.string   "reason_code"
    t.boolean  "be_used"
    t.integer  "be_used_count",        default: 0
    t.text     "comment"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["sign_card_setting_id"], name: "index_sign_card_reasons_on_sign_card_setting_id", using: :btree
  end

  create_table "sign_card_records", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.boolean  "is_compensate"
    t.boolean  "is_get_to_work"
    t.date     "sign_card_date"
    t.datetime "sign_card_time"
    t.integer  "sign_card_setting_id"
    t.integer  "sign_card_reason_id"
    t.text     "comment"
    t.boolean  "is_deleted"
    t.integer  "creator_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "source_id"
    t.boolean  "is_next",              default: false
    t.date     "input_date"
    t.string   "input_time"
    t.index ["creator_id"], name: "index_sign_card_records_on_creator_id", using: :btree
    t.index ["user_id"], name: "index_sign_card_records_on_user_id", using: :btree
  end

  create_table "sign_card_settings", force: :cascade do |t|
    t.string   "region"
    t.string   "code"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.text     "comment"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "sign_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "train_class_id"
    t.integer  "final_list_id"
    t.integer  "sign_status"
    t.string   "comment"
    t.integer  "working_status"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "train_id"
    t.index ["final_list_id"], name: "index_sign_lists_on_final_list_id", using: :btree
    t.index ["train_class_id"], name: "index_sign_lists_on_train_class_id", using: :btree
    t.index ["train_id"], name: "index_sign_lists_on_train_id", using: :btree
    t.index ["user_id"], name: "index_sign_lists_on_user_id", using: :btree
  end

  create_table "sms", force: :cascade do |t|
    t.string   "to"
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "status",        default: 0
    t.string   "title"
    t.string   "the_object"
    t.integer  "the_object_id"
    t.string   "mark"
    t.index ["user_id"], name: "index_sms_on_user_id", using: :btree
  end

  create_table "social_security_fund_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "year_month"
    t.decimal  "employee_payment_mop",      precision: 10, scale: 2
    t.decimal  "company_payment_mop",       precision: 10, scale: 2
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.datetime "career_entry_date"
    t.string   "employee_type"
    t.string   "employment_status"
    t.integer  "department_id"
    t.integer  "position_id"
    t.datetime "position_resigned_date"
    t.datetime "date_to_submit_fingermold"
    t.datetime "cancel_date"
    t.string   "company_name"
    t.string   "gender"
    t.datetime "date_of_birth"
    t.datetime "tax_declare_date"
    t.string   "type_of_id"
    t.string   "id_number"
    t.string   "sss_number"
    t.string   "tax_number"
    t.index ["department_id"], name: "index_social_security_fund_items_on_department_id", using: :btree
    t.index ["position_id"], name: "index_social_security_fund_items_on_position_id", using: :btree
    t.index ["user_id"], name: "index_social_security_fund_items_on_user_id", using: :btree
  end

  create_table "special_assessments", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.date     "apply_date"
    t.text     "employee_advantage"
    t.text     "employee_need_to_improve"
    t.text     "employee_opinion"
    t.text     "comment"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.jsonb    "salary_record"
    t.jsonb    "new_salary_record"
    t.string   "salary_calculation"
    t.index ["user_id"], name: "index_special_assessments_on_user_id", using: :btree
  end

  create_table "special_schedule_remarks", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "date_begin"
    t.datetime "date_end"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_special_schedule_remarks_on_user_id", using: :btree
  end

  create_table "special_schedule_settings", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "date_begin"
    t.datetime "date_end"
    t.text     "comment"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "target_location_id"
    t.integer  "target_department_id"
    t.index ["target_department_id"], name: "index_special_schedule_settings_on_target_department_id", using: :btree
    t.index ["target_location_id"], name: "index_special_schedule_settings_on_target_location_id", using: :btree
    t.index ["user_id"], name: "index_special_schedule_settings_on_user_id", using: :btree
  end

  create_table "staff_feedback_tracks", force: :cascade do |t|
    t.string   "track_status",      default: "untracked"
    t.string   "track_content"
    t.integer  "staff_feedback_id"
    t.integer  "tracker_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["staff_feedback_id"], name: "index_staff_feedback_tracks_on_staff_feedback_id", using: :btree
    t.index ["tracker_id"], name: "index_staff_feedback_tracks_on_tracker_id", using: :btree
  end

  create_table "staff_feedbacks", force: :cascade do |t|
    t.string   "feedback_title",         null: false
    t.text     "feedback_content",       null: false
    t.integer  "user_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "feedback_date"
    t.string   "feedback_track_status"
    t.integer  "feedback_tracker_id"
    t.datetime "feedback_track_date"
    t.string   "feedback_track_content"
    t.index ["feedback_tracker_id"], name: "index_staff_feedbacks_on_feedback_tracker_id", using: :btree
    t.index ["user_id"], name: "index_staff_feedbacks_on_user_id", using: :btree
  end

  create_table "stored_settings", force: :cascade do |t|
    t.string   "var",        null: false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["var"], name: "index_stored_settings_on_var", unique: true, using: :btree
  end

  create_table "student_evaluations", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "employment_status"
    t.integer  "training_type"
    t.integer  "lecturer_id"
    t.integer  "evaluation_status"
    t.date     "filled_in_date"
    t.text     "comment"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "train_id"
    t.string   "trainer"
    t.decimal  "satisfaction",      precision: 15, scale: 2
    t.index ["lecturer_id"], name: "index_student_evaluations_on_lecturer_id", using: :btree
    t.index ["train_id"], name: "index_student_evaluations_on_train_id", using: :btree
    t.index ["user_id"], name: "index_student_evaluations_on_user_id", using: :btree
  end

  create_table "suncity_charities", force: :cascade do |t|
    t.string   "current_status"
    t.string   "to_status"
    t.date     "valid_date"
    t.integer  "profile_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "supervisor_assessments", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "employment_status"
    t.integer  "exam_mode"
    t.integer  "training_result"
    t.integer  "attendance_rate"
    t.integer  "score"
    t.integer  "assessment_status"
    t.date     "filled_in_date"
    t.text     "comment"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "train_id"
    t.index ["user_id"], name: "index_supervisor_assessments_on_user_id", using: :btree
  end

  create_table "surplus_snapshots", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "year"
    t.integer  "holiday_type"
    t.integer  "surplus_count", default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "taken_holiday_records", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "holiday_record_id"
    t.datetime "taken_holiday_date"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "attend_id"
    t.index ["attend_id"], name: "index_taken_holiday_records_on_attend_id", using: :btree
    t.index ["holiday_record_id"], name: "index_taken_holiday_records_on_holiday_record_id", using: :btree
    t.index ["user_id"], name: "index_taken_holiday_records_on_user_id", using: :btree
  end

  create_table "timesheet_items", force: :cascade do |t|
    t.integer  "timesheet_id"
    t.string   "uid"
    t.date     "date"
    t.datetime "clock_in"
    t.datetime "clock_off"
    t.string   "init_state"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["timesheet_id"], name: "index_timesheet_items_on_timesheet_id", using: :btree
  end

  create_table "timesheets", force: :cascade do |t|
    t.string   "year"
    t.string   "month"
    t.integer  "department_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "roster_id"
    t.index ["department_id"], name: "index_timesheets_on_department_id", using: :btree
    t.index ["roster_id"], name: "index_timesheets_on_roster_id", using: :btree
  end

  create_table "titles", force: :cascade do |t|
    t.string   "name"
    t.integer  "col"
    t.integer  "train_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["train_id"], name: "index_titles_on_train_id", using: :btree
  end

  create_table "titles_users", id: false, force: :cascade do |t|
    t.integer "user_id",  null: false
    t.integer "title_id", null: false
    t.index ["user_id", "title_id"], name: "index_titles_users_on_user_id_and_title_id", using: :btree
  end

  create_table "train_classes", force: :cascade do |t|
    t.datetime "time_begin"
    t.datetime "time_end"
    t.integer  "row"
    t.integer  "title_id"
    t.integer  "train_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title_id"], name: "index_train_classes_on_title_id", using: :btree
    t.index ["train_id"], name: "index_train_classes_on_train_id", using: :btree
  end

  create_table "train_classes_users", id: false, force: :cascade do |t|
    t.integer "user_id",        null: false
    t.integer "train_class_id", null: false
    t.index ["user_id", "train_class_id"], name: "index_train_classes_users_on_user_id_and_train_class_id", using: :btree
  end

  create_table "train_record_by_trains", force: :cascade do |t|
    t.integer  "train_id"
    t.integer  "final_list_count"
    t.integer  "entry_list_count"
    t.integer  "invited_count"
    t.decimal  "attendance_rate",  precision: 10, scale: 2
    t.decimal  "passing_rate",     precision: 10, scale: 2
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.index ["train_id"], name: "index_train_record_by_trains_on_train_id", using: :btree
  end

  create_table "train_records", force: :cascade do |t|
    t.string   "empoid"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "department_chinese_name"
    t.string   "department_english_name"
    t.string   "department_simple_chinese_name"
    t.string   "position_chinese_name"
    t.string   "position_english_name"
    t.string   "position_simple_chinese_name"
    t.boolean  "train_result"
    t.decimal  "attendance_rate",                precision: 15, scale: 2
    t.integer  "train_id"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "cost",                           precision: 15, scale: 2
    t.index ["train_id"], name: "index_train_records_on_train_id", using: :btree
  end

  create_table "train_template_types", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "train_templates", force: :cascade do |t|
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "course_number"
    t.string   "teaching_form"
    t.integer  "train_template_type_id"
    t.decimal  "training_credits",                                       precision: 15, scale: 2
    t.integer  "online_or_offline_training"
    t.integer  "limit_number"
    t.decimal  "course_total_time",                                      precision: 15, scale: 2
    t.decimal  "course_total_count",                                     precision: 15, scale: 2
    t.string   "trainer"
    t.string   "language_of_training"
    t.string   "place_of_training"
    t.string   "contact_person_of_training"
    t.string   "course_series"
    t.string   "course_certificate"
    t.string   "introduction_of_trainee"
    t.string   "introduction_of_course"
    t.string   "goal_of_learning"
    t.string   "content_of_course"
    t.string   "goal_of_course"
    t.integer  "assessment_method"
    t.decimal  "test_scores_not_less_than",                              precision: 15, scale: 2
    t.integer  "exam_format"
    t.integer  "exam_template_id"
    t.decimal  "comprehensive_attendance_not_less_than",                 precision: 15, scale: 2
    t.decimal  "comprehensive_attendance_and_test_scores_not_less_than", precision: 15, scale: 2
    t.decimal  "test_scores_percentage",                                 precision: 15, scale: 2
    t.string   "notice"
    t.string   "comment"
    t.integer  "creator_id"
    t.datetime "created_at",                                                                      null: false
    t.datetime "updated_at",                                                                      null: false
    t.string   "simple_chinese_name"
    t.string   "questionnaire_template_chinese_name"
    t.string   "questionnaire_template_english_name"
    t.string   "questionnaire_template_simple_chinese_name"
    t.index ["creator_id"], name: "index_train_templates_on_creator_id", using: :btree
    t.index ["exam_template_id"], name: "index_train_templates_on_exam_template_id", using: :btree
    t.index ["train_template_type_id"], name: "index_train_templates_on_train_template_type_id", using: :btree
  end

  create_table "training_absentees", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "train_class_id"
    t.boolean  "has_submitted_reason"
    t.boolean  "has_been_exempted"
    t.string   "absence_reason"
    t.datetime "submit_date"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["train_class_id"], name: "index_training_absentees_on_train_class_id", using: :btree
    t.index ["user_id"], name: "index_training_absentees_on_user_id", using: :btree
  end

  create_table "training_courses", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "transfer_position_apply_by_employee_id"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "simple_chinese_name"
    t.string   "explanation"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["transfer_position_apply_by_employee_id"], name: "transfer_position_apply_by_employee_index", using: :btree
    t.index ["user_id"], name: "index_training_courses_on_user_id", using: :btree
  end

  create_table "training_papers", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "employment_status"
    t.integer  "exam_mode"
    t.integer  "score"
    t.integer  "attendance_rate"
    t.integer  "paper_status"
    t.integer  "correct_percentage"
    t.date     "filled_in_date"
    t.date     "latest_upload_date"
    t.text     "comment"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "train_id"
    t.index ["train_id"], name: "index_training_papers_on_train_id", using: :btree
    t.index ["user_id"], name: "index_training_papers_on_user_id", using: :btree
  end

  create_table "trains", force: :cascade do |t|
    t.integer  "train_template_id"
    t.string   "chinese_name"
    t.string   "english_name"
    t.datetime "train_date_begin"
    t.datetime "train_date_end"
    t.string   "train_place"
    t.decimal  "train_cost",                                             precision: 15, scale: 2
    t.datetime "registration_date_begin"
    t.datetime "registration_date_end"
    t.integer  "registration_method"
    t.integer  "limit_number"
    t.jsonb    "grade"
    t.jsonb    "division_of_job"
    t.string   "comment"
    t.integer  "status"
    t.datetime "created_at",                                                                                      null: false
    t.datetime "updated_at",                                                                                      null: false
    t.string   "simple_chinese_name"
    t.string   "train_number"
    t.decimal  "satisfaction_percentage",                                precision: 10, scale: 2
    t.integer  "by_invited",                                                                      default: [],                 array: true
    t.string   "train_template_chinese_name"
    t.string   "train_template_english_name"
    t.string   "train_template_simple_chinese_name"
    t.string   "course_number"
    t.string   "teaching_form"
    t.integer  "train_template_type_id"
    t.decimal  "training_credits",                                       precision: 15, scale: 2, default: "0.0"
    t.integer  "online_or_offline_training"
    t.integer  "train_template_limit_number"
    t.decimal  "course_total_time",                                      precision: 15, scale: 2
    t.decimal  "course_total_count",                                     precision: 15, scale: 2
    t.string   "trainer"
    t.string   "language_of_training"
    t.string   "place_of_training"
    t.string   "contact_person_of_training"
    t.string   "course_series"
    t.string   "course_certificate"
    t.string   "introduction_of_trainee"
    t.string   "introduction_of_course"
    t.string   "goal_of_learning"
    t.string   "content_of_course"
    t.string   "goal_of_course"
    t.integer  "assessment_method"
    t.decimal  "test_scores_not_less_than",                              precision: 15, scale: 2
    t.integer  "exam_format"
    t.integer  "exam_template_id"
    t.decimal  "comprehensive_attendance_not_less_than",                 precision: 15, scale: 2
    t.decimal  "comprehensive_attendance_and_test_scores_not_less_than", precision: 15, scale: 2
    t.decimal  "test_scores_percentage",                                 precision: 15, scale: 2
    t.string   "train_template_notice"
    t.string   "train_template_comment"
    t.index ["train_template_id"], name: "index_trains_on_train_template_id", using: :btree
  end

  create_table "trains_users", id: false, force: :cascade do |t|
    t.integer "train_id", null: false
    t.integer "user_id",  null: false
    t.index ["train_id", "user_id"], name: "index_trains_users_on_train_id_and_user_id", using: :btree
  end

  create_table "transfer_location_applies", force: :cascade do |t|
    t.string   "region"
    t.date     "apply_date"
    t.text     "comment"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "salary_calculation"
  end

  create_table "transfer_location_items", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.integer  "transfer_location_apply_id"
    t.date     "transfer_date"
    t.integer  "transfer_location_id"
    t.text     "comment"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "salary_calculation"
    t.index ["transfer_location_apply_id"], name: "index_transfer_location_items_on_transfer_location_apply_id", using: :btree
    t.index ["transfer_location_id"], name: "index_transfer_location_items_on_transfer_location_id", using: :btree
    t.index ["user_id"], name: "index_transfer_location_items_on_user_id", using: :btree
  end

  create_table "transfer_position_apply_by_departments", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.text     "comment"
    t.date     "apply_date"
    t.date     "apply_serve_date"
    t.integer  "apply_location_id"
    t.integer  "apply_department_id"
    t.integer  "apply_position_id"
    t.text     "transfer_position_reason_by_department"
    t.boolean  "is_agreed_by_employee"
    t.text     "employee_opinion"
    t.boolean  "is_hired"
    t.boolean  "need_pass_trial"
    t.integer  "hire_position_id"
    t.date     "effective_date"
    t.text     "department_comment"
    t.boolean  "is_transfer"
    t.date     "transfer_date"
    t.integer  "transfer_location_id"
    t.integer  "transfer_department_id"
    t.integer  "transfer_position_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.jsonb    "salary_record"
    t.jsonb    "new_salary_record"
    t.jsonb    "welfare_record"
    t.jsonb    "new_welfare_record"
    t.string   "salary_calculation"
    t.integer  "apply_group_id"
    t.integer  "transfer_group_id"
    t.index ["apply_department_id"], name: "tp_apply_department_index_111", using: :btree
    t.index ["apply_group_id"], name: "tp_apply_group_index", using: :btree
    t.index ["apply_location_id"], name: "tp_apply_location_index", using: :btree
    t.index ["apply_position_id"], name: "tp_apply_position_index", using: :btree
    t.index ["transfer_department_id"], name: "tp_transfer_department_index", using: :btree
    t.index ["transfer_group_id"], name: "tp_transfer_group_index", using: :btree
    t.index ["transfer_location_id"], name: "tp_transfer_location_index", using: :btree
    t.index ["transfer_position_id"], name: "tp_transfer_position_index", using: :btree
    t.index ["user_id"], name: "tp_user_index", using: :btree
  end

  create_table "transfer_position_apply_by_employees", force: :cascade do |t|
    t.string   "region"
    t.integer  "user_id"
    t.text     "comment"
    t.date     "apply_date"
    t.integer  "apply_location_id"
    t.integer  "apply_department_id"
    t.integer  "apply_position_id"
    t.boolean  "is_recommended_by_department"
    t.string   "reason"
    t.boolean  "is_continued"
    t.date     "interview_date_by_department"
    t.datetime "interview_time_by_department"
    t.string   "interview_location_by_department"
    t.date     "interview_date_by_header"
    t.datetime "interview_time_by_header"
    t.string   "interview_location_by_header"
    t.boolean  "is_transfer"
    t.date     "transfer_date"
    t.integer  "transfer_location_id"
    t.integer  "transfer_department_id"
    t.integer  "transfer_position_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "apply_reason"
    t.boolean  "interview_result_by_department"
    t.text     "interview_comment_by_department"
    t.boolean  "interview_result_by_header"
    t.text     "interview_comment_by_header"
    t.jsonb    "salary_record"
    t.jsonb    "new_salary_record"
    t.jsonb    "welfare_record"
    t.jsonb    "new_welfare_record"
    t.string   "salary_calculation"
    t.integer  "apply_group_id"
    t.integer  "transfer_group_id"
    t.index ["apply_department_id"], name: "tp_a_by_emp_apply_department_index", using: :btree
    t.index ["apply_group_id"], name: "tp_a_by_emp_apply_group_index", using: :btree
    t.index ["apply_location_id"], name: "tp_a_by_emp_apply_location_index", using: :btree
    t.index ["apply_position_id"], name: "tp_a_by_emp_apply_position_index", using: :btree
    t.index ["transfer_department_id"], name: "tp_a_by_emp_transfer_department_index", using: :btree
    t.index ["transfer_group_id"], name: "tp_a_by_emp_transfer_group_index", using: :btree
    t.index ["transfer_location_id"], name: "tp_a_by_emp_transfer_location_index", using: :btree
    t.index ["transfer_position_id"], name: "tp_a_by_emp_transfer_position_index", using: :btree
    t.index ["user_id"], name: "tp_a_by_emp_user_index", using: :btree
  end

  create_table "typhoon_qualified_records", force: :cascade do |t|
    t.string   "region"
    t.integer  "typhoon_setting_id"
    t.integer  "user_id"
    t.boolean  "is_compensate"
    t.date     "qualify_date"
    t.integer  "money"
    t.boolean  "is_apply"
    t.string   "working_hours"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["typhoon_setting_id"], name: "index_typhoon_qualified_records_on_typhoon_setting_id", using: :btree
    t.index ["user_id"], name: "index_typhoon_qualified_records_on_user_id", using: :btree
  end

  create_table "typhoon_settings", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "qualify_counts"
    t.integer  "apply_counts"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "empoid"
    t.string   "chinese_name"
    t.string   "english_name"
    t.string   "password_digest"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "position_id"
    t.integer  "location_id"
    t.integer  "department_id"
    t.string   "id_card_number"
    t.string   "email"
    t.string   "superior_email"
    t.string   "company_name"
    t.string   "employment_status"
    t.string   "simple_chinese_name"
    t.integer  "grade"
    t.integer  "group_id"
    t.index ["chinese_name"], name: "index_users_on_chinese_name", using: :btree
    t.index ["company_name"], name: "index_users_on_company_name", using: :btree
    t.index ["department_id"], name: "index_users_on_department_id", using: :btree
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["employment_status"], name: "index_users_on_employment_status", using: :btree
    t.index ["empoid"], name: "index_users_on_empoid", using: :btree
    t.index ["english_name"], name: "index_users_on_english_name", using: :btree
    t.index ["group_id"], name: "index_users_on_group_id", using: :btree
    t.index ["id_card_number"], name: "index_users_on_id_card_number", using: :btree
    t.index ["location_id"], name: "index_users_on_location_id", using: :btree
    t.index ["position_id"], name: "index_users_on_position_id", using: :btree
    t.index ["superior_email"], name: "index_users_on_superior_email", using: :btree
  end

  create_table "vip_halls_trainers", force: :cascade do |t|
    t.integer  "vip_halls_train_id"
    t.datetime "train_date_begin"
    t.datetime "train_date_end"
    t.integer  "length_of_training_time"
    t.string   "train_content"
    t.integer  "user_id"
    t.string   "train_type"
    t.integer  "number_of_students"
    t.integer  "total_accepted_training_time"
    t.string   "remarks"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["user_id"], name: "index_vip_halls_trainers_on_user_id", using: :btree
    t.index ["vip_halls_train_id"], name: "index_vip_halls_trainers_on_vip_halls_train_id", using: :btree
  end

  create_table "vip_halls_trains", force: :cascade do |t|
    t.integer  "location_id"
    t.datetime "train_month"
    t.boolean  "locked"
    t.integer  "employee_amount"
    t.integer  "training_minutes_available"
    t.integer  "training_minutes_accepted"
    t.integer  "training_minutes_per_employee"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["location_id"], name: "index_vip_halls_trains_on_location_id", using: :btree
  end

  create_table "welfare_records", force: :cascade do |t|
    t.string   "change_reason"
    t.datetime "welfare_begin"
    t.datetime "welfare_end"
    t.decimal  "annual_leave",           precision: 10, scale: 2
    t.decimal  "sick_leave",             precision: 10, scale: 2
    t.decimal  "office_holiday",         precision: 10, scale: 2
    t.integer  "welfare_template_id"
    t.string   "holiday_type"
    t.decimal  "probation",              precision: 10, scale: 2
    t.decimal  "notice_period",          precision: 10, scale: 2
    t.boolean  "double_pay"
    t.boolean  "reduce_salary_for_sick"
    t.boolean  "provide_uniform"
    t.string   "salary_composition"
    t.string   "over_time_salary"
    t.string   "force_holiday_make_up"
    t.string   "comment"
    t.integer  "user_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.datetime "valid_date"
    t.datetime "invalid_date"
    t.string   "order_key"
    t.string   "position_type"
    t.integer  "work_days_every_week"
    t.index ["user_id"], name: "index_welfare_records_on_user_id", using: :btree
    t.index ["welfare_template_id"], name: "index_welfare_records_on_welfare_template_id", using: :btree
  end

  create_table "welfare_templates", force: :cascade do |t|
    t.string   "template_chinese_name",                     null: false
    t.string   "template_english_name",                     null: false
    t.integer  "annual_leave",                              null: false
    t.integer  "sick_leave",                                null: false
    t.float    "office_holiday",                            null: false
    t.integer  "holiday_type",                              null: false
    t.integer  "probation",                                 null: false
    t.integer  "notice_period",                             null: false
    t.boolean  "double_pay",                                null: false
    t.boolean  "reduce_salary_for_sick",                    null: false
    t.boolean  "provide_uniform",                           null: false
    t.integer  "over_time_salary",                          null: false
    t.string   "comment"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.jsonb    "belongs_to",                   default: {}
    t.string   "template_simple_chinese_name"
    t.integer  "force_holiday_make_up"
    t.string   "salary_composition"
    t.string   "position_type"
    t.integer  "work_days_every_week"
    t.index ["template_chinese_name"], name: "index_welfare_templates_on_template_chinese_name", using: :btree
    t.index ["template_english_name"], name: "index_welfare_templates_on_template_english_name", using: :btree
  end

  create_table "whether_together_preferences", force: :cascade do |t|
    t.integer  "roster_preference_id"
    t.string   "group_name"
    t.integer  "group_members",        default: [],              array: true
    t.string   "date_range"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "comment"
    t.boolean  "is_together"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["roster_preference_id"], name: "index_whether_together_preferences_on_roster_preference_id", using: :btree
  end

  create_table "work_experences", force: :cascade do |t|
    t.string   "company_organazition"
    t.string   "work_experience_position"
    t.string   "job_description"
    t.integer  "work_experience_salary"
    t.string   "work_experience_reason_for_leaving"
    t.integer  "work_experience_company_phone_number"
    t.string   "former_head"
    t.string   "work_experience_email"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.datetime "work_experience_from"
    t.datetime "work_experience_to"
    t.integer  "profile_id"
    t.integer  "creator_id"
    t.index ["creator_id"], name: "index_work_experences_on_creator_id", using: :btree
    t.index ["profile_id"], name: "index_work_experences_on_profile_id", using: :btree
  end

  create_table "working_hours_transaction_records", force: :cascade do |t|
    t.string   "region"
    t.boolean  "is_compensate"
    t.integer  "user_a_id"
    t.integer  "user_b_id"
    t.integer  "apply_type"
    t.date     "apply_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "hours_count"
    t.boolean  "is_deleted"
    t.text     "comment"
    t.integer  "creator_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "source_id"
    t.integer  "borrow_id"
    t.boolean  "is_start_next", default: false
    t.boolean  "is_end_next",   default: false
    t.boolean  "can_be_return", default: true
    t.index ["creator_id"], name: "index_working_hours_transaction_records_on_creator_id", using: :btree
    t.index ["user_a_id"], name: "index_working_hours_transaction_records_on_user_a_id", using: :btree
    t.index ["user_b_id"], name: "index_working_hours_transaction_records_on_user_b_id", using: :btree
  end

  create_table "wrwts", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "provide_airfare"
    t.boolean  "provide_accommodation"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "airfare_type"
    t.integer  "airfare_count"
  end

  add_foreign_key "accounting_statement_month_items", "users"
  add_foreign_key "annual_bonus_items", "users"
  add_foreign_key "appraisal_attachments", "attachments"
  add_foreign_key "appraisal_department_settings", "appraisal_basic_settings"
  add_foreign_key "appraisal_department_settings", "departments"
  add_foreign_key "appraisal_department_settings", "locations"
  add_foreign_key "appraisal_department_settings", "questionnaire_templates", column: "group_A_appraisal_template_id"
  add_foreign_key "appraisal_department_settings", "questionnaire_templates", column: "group_B_appraisal_template_id"
  add_foreign_key "appraisal_department_settings", "questionnaire_templates", column: "group_C_appraisal_template_id"
  add_foreign_key "appraisal_department_settings", "questionnaire_templates", column: "group_D_appraisal_template_id"
  add_foreign_key "appraisal_department_settings", "questionnaire_templates", column: "group_E_appraisal_template_id"
  add_foreign_key "appraisal_employee_settings", "appraisal_groups"
  add_foreign_key "appraisal_employee_settings", "users"
  add_foreign_key "appraisal_for_departments", "appraisals"
  add_foreign_key "appraisal_for_departments", "departments"
  add_foreign_key "appraisal_for_users", "appraisal_for_departments"
  add_foreign_key "appraisal_for_users", "appraisals"
  add_foreign_key "appraisal_for_users", "users"
  add_foreign_key "appraisal_overall_scores", "appraisals"
  add_foreign_key "appraisal_participate_departments", "appraisals"
  add_foreign_key "appraisal_participate_departments", "departments"
  add_foreign_key "appraisal_participate_departments", "locations"
  add_foreign_key "appraisal_participators", "appraisal_department_settings"
  add_foreign_key "appraisal_participators", "appraisal_employee_settings"
  add_foreign_key "appraisal_participators", "appraisals"
  add_foreign_key "appraisal_participators", "departments"
  add_foreign_key "appraisal_participators", "locations"
  add_foreign_key "appraisal_participators", "users"
  add_foreign_key "appraisal_questionnaires", "appraisal_participators"
  add_foreign_key "appraisal_questionnaires", "appraisals"
  add_foreign_key "appraisal_questionnaires", "questionnaires"
  add_foreign_key "appraisal_questionnaires", "users", column: "assessor_id"
  add_foreign_key "appraisal_reports", "appraisal_participators"
  add_foreign_key "appraisal_reports", "appraisals"
  add_foreign_key "approval_items", "users"
  add_foreign_key "assess_relationships", "appraisals"
  add_foreign_key "assess_relationships", "users", column: "assessor_id"
  add_foreign_key "attachment_items", "attachments"
  add_foreign_key "attendance_items", "locations"
  add_foreign_key "attendance_items", "roster_items"
  add_foreign_key "attendance_month_report_items", "users"
  add_foreign_key "attendances", "rosters"
  add_foreign_key "bonus_element_item_values", "bonus_element_items"
  add_foreign_key "bonus_element_item_values", "bonus_elements"
  add_foreign_key "bonus_element_items", "departments"
  add_foreign_key "bonus_element_items", "locations"
  add_foreign_key "bonus_element_items", "positions"
  add_foreign_key "bonus_element_items", "users"
  add_foreign_key "bonus_element_month_amounts", "bonus_elements"
  add_foreign_key "bonus_element_month_amounts", "float_salary_month_entries"
  add_foreign_key "bonus_element_month_amounts", "locations"
  add_foreign_key "bonus_element_month_personals", "bonus_elements"
  add_foreign_key "bonus_element_month_personals", "float_salary_month_entries"
  add_foreign_key "bonus_element_month_personals", "users"
  add_foreign_key "bonus_element_month_shares", "bonus_elements"
  add_foreign_key "bonus_element_month_shares", "float_salary_month_entries"
  add_foreign_key "bonus_element_month_shares", "locations"
  add_foreign_key "bonus_element_settings", "bonus_elements"
  add_foreign_key "bonus_element_settings", "departments"
  add_foreign_key "bonus_element_settings", "locations"
  add_foreign_key "candidate_relationships", "appraisal_participators", column: "candidate_participator_id"
  add_foreign_key "candidate_relationships", "appraisals"
  add_foreign_key "card_attachments", "card_profiles"
  add_foreign_key "card_histories", "card_profiles"
  add_foreign_key "card_records", "card_profiles"
  add_foreign_key "client_comment_tracks", "client_comments"
  add_foreign_key "client_comment_tracks", "users"
  add_foreign_key "client_comments", "users"
  add_foreign_key "client_comments", "users", column: "last_tracker_id"
  add_foreign_key "dimission_follow_ups", "dimissions"
  add_foreign_key "dimissions", "users"
  add_foreign_key "dimissions", "users", column: "creator_id"
  add_foreign_key "dismission_salary_items", "dimissions"
  add_foreign_key "dismission_salary_items", "users"
  add_foreign_key "empo_cards", "approved_jobs"
  add_foreign_key "force_holiday_working_records", "attends"
  add_foreign_key "force_holiday_working_records", "holiday_settings"
  add_foreign_key "force_holiday_working_records", "users"
  add_foreign_key "goods_category_managements", "users", column: "creator_id"
  add_foreign_key "goods_signings", "goods_categories"
  add_foreign_key "goods_signings", "users"
  add_foreign_key "goods_signings", "users", column: "distributor_id"
  add_foreign_key "holiday_items", "holidays"
  add_foreign_key "holiday_switch_items", "holiday_switches"
  add_foreign_key "holidays", "users"
  add_foreign_key "love_funds", "users"
  add_foreign_key "medical_insurance_participators", "users"
  add_foreign_key "medical_items", "medical_item_templates"
  add_foreign_key "medical_items", "medical_templates"
  add_foreign_key "medical_reimbursements", "medical_items"
  add_foreign_key "medical_reimbursements", "medical_templates"
  add_foreign_key "medical_reimbursements", "users"
  add_foreign_key "medical_reimbursements", "users", column: "tracker_id"
  add_foreign_key "month_salary_change_records", "salary_records", column: "original_salary_record_id"
  add_foreign_key "month_salary_change_records", "salary_records", column: "updated_salary_record_id"
  add_foreign_key "month_salary_change_records", "users"
  add_foreign_key "occupation_tax_items", "users"
  add_foreign_key "payroll_items", "users"
  add_foreign_key "performance_interviews", "appraisal_participators"
  add_foreign_key "performance_interviews", "appraisals"
  add_foreign_key "performance_interviews", "users", column: "operator_id"
  add_foreign_key "performance_interviews", "users", column: "performance_moderator_id"
  add_foreign_key "professional_qualifications", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "punishments", "users"
  add_foreign_key "punishments", "users", column: "tracker_id"
  add_foreign_key "report_columns", "reports"
  add_foreign_key "reserved_holiday_participators", "reserved_holiday_settings"
  add_foreign_key "reserved_holiday_participators", "users"
  add_foreign_key "reserved_holiday_settings", "users", column: "creator_id"
  add_foreign_key "revision_histories", "appraisal_questionnaires"
  add_foreign_key "revision_histories", "users"
  add_foreign_key "roster_settings", "rosters"
  add_foreign_key "salary_element_factors", "salary_elements"
  add_foreign_key "salary_elements", "salary_element_categories"
  add_foreign_key "social_security_fund_items", "users"
  add_foreign_key "special_schedule_remarks", "users"
  add_foreign_key "special_schedule_settings", "departments", column: "target_department_id"
  add_foreign_key "special_schedule_settings", "locations", column: "target_location_id"
  add_foreign_key "special_schedule_settings", "users"
  add_foreign_key "staff_feedback_tracks", "staff_feedbacks"
  add_foreign_key "staff_feedback_tracks", "users", column: "tracker_id"
  add_foreign_key "staff_feedbacks", "users"
  add_foreign_key "staff_feedbacks", "users", column: "feedback_tracker_id"
  add_foreign_key "taken_holiday_records", "attends"
  add_foreign_key "taken_holiday_records", "holiday_records"
  add_foreign_key "taken_holiday_records", "users"
  add_foreign_key "train_record_by_trains", "trains"
  add_foreign_key "training_absentees", "train_classes"
  add_foreign_key "training_absentees", "users"
  add_foreign_key "users", "groups"
  add_foreign_key "vip_halls_trainers", "users"
  add_foreign_key "vip_halls_trainers", "vip_halls_trains"
  add_foreign_key "vip_halls_trains", "locations"
end
