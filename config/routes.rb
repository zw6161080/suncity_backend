require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :entry_and_leave_statistics, only: [:index] do
    collection do
      get :columns
      get :options
    end
  end
  resources :turnover_rate, only: [:index] do
    collection do
      get :columns
      get :options
    end
  end
  resources :month_salary_change_records, only: [:index] do
    collection do
      get :columns
      get :options
    end
  end
  resources :pass_entry_trial_records, only: [:index] do
    collection do
      get :columns
      get :options
    end
  end
  resources :professional_qualifications, only: [:index, :update, :destroy] do
    collection do
      get :columns
      get :options
    end
  end
  resources :education_informations, only: [:index] do
    collection do
      get :columns
      get :options
    end
  end
  resources :work_experences, only: [:index] do
    collection do
      get :columns
      get :options
    end
  end
  resources :groups, except: [:show] do
    member do
      get :can_destroy
    end
    collection do
      get :options_for_profile_create
    end
  end
  resources :entry_waited_records, only: [:index] do
    collection do
      get :field_options
    end
  end
  resources :special_schedule_remarks, except: [:show] do
    collection do
      get :columns
      get :index_by_user
      get :options
    end
  end
  resources :holiday_accumulation_records, only: [:index] do
    collection do
      get :options
    end
  end

  resources :contract_information_types


  resources :air_ticket_reimbursements do
    collection do
      get :index_by_user
    end
  end
  resources :reserved_holiday_participators, except: [:show]


  resources :roster_instructions, only: [:update]

  resources :force_holiday_working_records, only: [:index] do
    collection do
      get :columns
      get :options
    end
  end
  resources :taken_holiday_records, only: [:index] do
    collection do
      get :columns
      get :options
    end
  end
  resources :special_schedule_settings, except: [:show] do
    collection do
      get :columns
      get :options
      post :check_params
    end
  end
  resources :reserved_holiday_participators, except: [:show, :index, :create, :update] do
    collection do
      get :columns
      get :options
    end
  end

  resources :reserved_holiday_settings do
    collection do
      get :columns
      # get :options
    end
    resources :reserved_holiday_participators, only: [:create, :index] do
      collection do
        post :whether_user_added
      end
    end
  end

  resources :month_salary_attachments, only: :show
  get 'query_medical_conditions', to: 'medical_reimbursements#query_medical_conditions'
  resources :salary_values do
    member do
      patch :update_value
    end
  end

  resources :grant_type_details
  resources :annual_award_report_items do
    collection do
      get :options
      get :columns
    end
  end
  resources :annual_award_reports do
    member do
      patch :grant
    end
    collection do
      get :grant_type_options
    end
  end
  resources :pay_slips do
    collection do
      get :index_by_mine
      get :index_by_department
      get :columns
      get :options
    end
  end
  resources :salary_values
  resources :month_salary_reports do
    member do
      get :show_by_options
      patch :cancel
      patch :preliminary_examine
      patch :president_examine
      patch 'examine_by_user/:user_id', to: 'month_salary_reports#examine_by_user'
      patch 'update_by_user/:user_id', to: 'month_salary_reports#update_by_user'
      get :show_export
    end
    collection do
      get :index_by_left_options
      get :index_options
      get :options
      get :index_by_left
      get :index_by_left_export
      get :index_export
    end
  end
  resources :salary_columns
  resources :salary_column_templates do
    member do
      patch :set_default
    end
    collection do
      get :get_default_template
      get :all_columns
    end
  end
  resources :award_records do
    collection do
      get :index_by_user
    end
  end
  resources :medical_records do
    collection do
      get :index_by_user
    end
  end
  resources :love_fund_records do
    collection do
      get :index_by_user
    end
  end

  resources :wrwts do
    collection do
      get :wrwt_information_options
      get :current_wrwt_by_user
    end
  end
  resources :resignation_records do
    member do
      get :month_salary_report_item_has_granted
    end
    collection do
      get :resignation_information_options
      get :index_by_user
    end
  end

  resources :lent_records do
    collection do
      post :can_create
      post :can_update
      get :lent_information_options
      get :index_by_user
      get :temporary_stadium_is_ok
    end
  end

  resources :museum_records do
    collection do
      post :can_create
      post :can_update
      get :museum_information_options
      get :index_by_user
      get :location_is_ok
    end

  end
  resources :career_records do
    collection do
      post :can_create
      post :can_update
      get :career_information_options
      get :index_by_user
    end
  end

  resources :salary_records do
    collection do
      get :columns
      get :options
      get :salary_information_options
      get :index_by_user
      get :current_salary_record_by_user
      get :current_salary_record_by_user_from_job_transfer
      get :current_salary_record_and_coming_salary_record
    end
  end

  resources :welfare_records do
    collection do
      get :columns
      get :options
      get :welfare_information_options
      get :index_by_user
      get :current_welfare_record_by_user
      get :current_welfare_record_by_user_from_job_transfer
      get :current_welfare_record_and_coming_welfare_record
    end
  end

  resources :appraisal_employee_settings do
    collection do
      get :field_options
      get :side_bar_options
    end
  end

  resources :appraisal_department_settings do
    collection do
      patch :batch_update
      get   :location_with_departments
      get   :fields_options
    end
    member do
      patch :update_group_situation
    end
    resources :appraisal_groups, only: [:update, :create, :destroy]
  end

  get 'appraisal_basic_setting/attachments', to: 'appraisal_attachments#index'
  post 'appraisal_basic_setting/attachments', to: 'appraisal_attachments#create'
  patch 'appraisal_basic_setting/attachments/:id', to: 'appraisal_attachments#update'
  delete 'appraisal_basic_setting/attachments/:id', to: 'appraisal_attachments#destroy'

  get 'appraisals/all_appraisal_report_record', to: 'appraisal_reports#all_appraisal_report_record'
  get 'appraisals/all_appraisal_report_record_columns', to: 'appraisal_reports#all_appraisal_report_record_columns'

  resource :appraisal_basic_setting, only: [:show, :update]

  resources :appraisal_participate_departments

  resources :appraisal_for_users, only: [:index]

  resources :appraisal_for_departments, only: [:index]

  resources :appraisals do
    collection do
      get :options
      post :can_create
      get :download
      get :index_by_department
      get :index_by_mine
    end

    member do
      post :initiate
      post :complete
      post :release_reports
      post :performance_interview
      get :complete_or_no
      get :performance_interview_check
    end

    resources :appraisal_participators do
      collection do
        get    :index_by_department
        get    :index_by_mine
        post   :auto_assign
        get    :can_add_to_participator_list
        get    :options
        get    :side_bar_options
        get    :not_filled_participators
        get    :index_by_distribution
        patch  :departmental_confirm
      end
      member do
        post   :create_assessor
        delete :destroy_assessor
      end
    end

    resources :appraisal_questionnaires do
      collection do
        get :index_by_department
        get :index_by_mine
        patch :save
        patch :batch_save
        patch :submit
        patch :batch_submit
        post :can_submit
        post :can_batch_submit
        get :show_by_assessor
        get :columns
        get :options
      end

      member do
        patch :revise
      end
    end

    resources :performance_interviews do
      collection do
        get :index_by_department
        get :index_by_mine
        get :columns
        get :options
        get :side_bar_options
        patch :update
        patch :completed
      end
    end

    resources :appraisal_reports do
      collection do
        get :index_by_department
        get :index_by_mine
        get :columns
        get :options
        get :side_bar_options
      end
    end

  end

  get 'appraisal_records/appraisal_reports', to: 'appraisal_reports#all_appraisal_report_record'
  get 'appraisal_records/appraisal_reports/columns', to: 'appraisal_reports#all_appraisal_report_record_columns'
  get 'appraisal_records/appraisal_reports/options', to: 'appraisal_reports#record_options'

  get 'appraisal_records/appraisal_questionnaires/records', to: 'appraisal_questionnaires#record_index'
  get 'appraisal_records/appraisal_questionnaires/columns', to: 'appraisal_questionnaires#record_columns'
  get 'appraisal_records/appraisal_questionnaires/options', to: 'appraisal_questionnaires#record_options'

  get 'appraisal_records/performance_interviews/records', to: 'performance_interviews#record_index'
  get 'appraisal_records/performance_interviews/columns', to: 'performance_interviews#record_columns'
  get 'appraisal_records/performance_interviews/options', to: 'performance_interviews#record_options'

  get 'appraisals/:appraisal_id/appraisal_questionnaires/show_by_assessor/:user_id', to: 'appraisal_questionnaires#show_by_assessor'

  resources :sign_lists

  resources :final_lists do
    member do
      patch :train_result
    end
  end

  resources :entry_lists do
    collection do
      post :can_create
      patch :batch_update_and_to_final_lists
    end
  end

  resources :train_classes do
    collection do
      get :index_trains
    end
  end

  resources :train_record_by_trains do
    collection do
      get :columns
      get :options
      get :export
    end
  end


  resources :client_comments do
    resources :client_comment_tracks
    collection do
      get :columns
      get :options
      get :export
      get :show_tracker
    end
  end

  resources :train_template_types do
    member do
      get :can_be_delete
    end
    collection do
      patch :batch_update
    end
  end
  resources :training_absentees do
    collection do
      get :columns
      get :options
      get :export
    end
  end

  resources :vip_halls_trainers do
    collection do
      get :columns
      get :export
      get :month_options
    end
  end

  resources :vip_halls_trains do
    member do
      patch :lock
    end
    collection do
      get :field_options
      get :options_of_all_locations
      get :which_locations_can_be_chosen
    end
  end

  resources :train_templates do
    # member do
    #   get :download
    # end
    collection do
      get :field_options
      get :all_templates
    end
  end
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :provident_funds do
    collection do
      get :field_options
      get :create_options
    end
  end

  resources :payroll_reports do
    collection do
      get :company_options
    end
    member do
      patch :grant
      patch :setup
    end
  end
  resources :accounting_statement_month_reports do
    collection do
      get :company_options
    end
    member do
      patch :grant
      patch :setup
    end
  end
  resources :medical_item_templates, only: [:index, :create]
  resources :bank_auto_pay_report_items do
    collection do
      get :columns
      get :options
    end
  end
  resources :goods_signings do
    member do
      get :signing
    end
    collection do
      get :columns
      get :options
    end
  end

  resources :goods_categories do
    collection do
      get :columns
      get :options
      get :get_list
    end
  end

  resources :departure_employee_taxpayer_numbering_report_items     do
    member do
      patch :update_beneficiary_name
    end
    collection do
      get :columns
      get :options
    end
  end

  resources :employee_redemption_report_items  do
    collection do
      get :columns
      get :options
    end
  end
  resources :provident_fund_member_report_items do
    collection do
      get :columns
      get :options
    end
  end

  resources :goods_category_managements

  resources :bonus_element_item_values, except: [:index, :create, :destroy]
  resources :bonus_element_items, except: [:create, :destroy] do
    collection do
      get :options
    end
  end
  resources :employee_fund_switching_report_items do
    collection do
      get :columns
      get :options
    end
  end
  resources :contribution_report_items  do
    collection do
      get :columns
      get :options
      get :year_month_options
    end
  end

  resources :medical_reimbursements do
    member do
      get :update_from_profile
      get :destroy_from_profile
      get :send_message
      get :show_medical_items
      get :if_participate_medical_insurance
    end
    collection do
      post :create_from_profile
      get :download_from_profile
      get :download
      get :export
      get :field_options
    end
  end

  resources :medical_insurance_participators do
    collection do
      get :field_options
      get :export
      patch :batch_update
    end
  end

  resources :payroll_items do
    collection do
      get :columns
      get :options
      get :departmental
      get :personal
      get :business_consultant_columns
      get :business_consultant_data
    end
    member do
      get :export
    end
  end

  resources :social_security_fund_items, except: [:show, :update, :create, :destroy] do
    collection do
      get :columns
      get :options
      get :year_month_options
    end
  end

  resources :dismission_salary_items, except: [:show, :update, :create, :destroy] do
    collection do
      get :columns
      get :options
    end
    member do
      patch :approve
    end
  end

  resources :annual_bonus_events, except: [:update] do
    member do
      patch :grant
    end
  end
  resources :annual_bonus_items, except: [:show, :update, :create, :destroy] do
    collection do
      get :columns
      get :options
    end
  end

  resources :occupation_tax_items, except: [:show, :update, :create, :destroy] do
    collection do
      post :import
      get :columns
      get :options
      get :year_options
    end
    member do
      patch :update_comment
    end
  end

  resource :medical_template_settings, only: [:show, :update]
  resources :medical_templates do
    collection do
      get :create_permission
    end
  end
  resources :medical_items, only: [:index, :create, :destroy]

  resource :occupation_tax_settings do
    collection do
      patch :reset
    end
  end

  resources :bonus_element_month_personals, except: [:create, :destroy]
  resources :bonus_element_month_amounts, except: [:create, :destroy] do
    collection do
      patch :batch_update
    end
  end
  resources :bonus_element_month_shares, except: [:create, :destroy] do
    collection do
      patch :batch_update
    end
  end
  resources :bonus_elements
  resources :bonus_element_settings do
    collection do
      patch :batch_update
      patch :reset
    end
  end
  resources :float_salary_month_entries do
    member do
      get :show_for_search
      post :bonus_element_items
      post :import_amounts
      get :export_amounts
      get :locations_with_departments
      post :import_bonus_element_items
    end
    collection do
      get :check
      get :year_month_options
      get :approved_year_month_options
    end
  end

  resources :salary_element_categories, except: [:show, :update, :create, :destroy] do
    collection do
      patch :reset
    end
  end

  resources :salary_element_factors, only: [:batch_update] do
    patch :batch_update, on: :collection
  end
  resources :salary_elements, shallow: true do
    resources :salary_element_factors
  end

  resources :reports do
    member do
      get :rows
    end
  end

  resources :accounting_statement_month_items, except: [:show] do
    collection do
      get :columns
      get :options
      get :business_consultant_columns
      get :business_consultant_data
      get :all_columns
      get :all_data
    end
  end

  resources :attendance_month_report_items, except: [:show, :update, :create, :destroy] do
    collection do
      get :columns
      get :options
      get :year_month_options
    end
  end

  resources :love_funds do
    collection do
      get :field_options
      get :export
      patch :batch_update
    end
  end

  resources :punishments do
    member do
      get :index_by_empoid_or_name
    end
    collection do
      get :field_options
      get :export
      get :show_profile
      get :profile_index
      get :profile_show
      post :profile_create
      patch :profile_update
    end
  end

  resources :staff_feedbacks do
    resources :staff_feedback_tracks
    collection do
      get :index_my_feedbacks
      get :field_options
      get :export_all_feedbacks
    end
  end

  resources :dimission_follow_ups, except: [:create, :destroy]
  resources :dimissions, except: [:update, :destroy] do
    collection do
      get :apply_options
      get :field_options
      get :termination_compensation
    end
  end
  resources :empo_cards, :except => :show do
    collection do
      get :destroy_job_with_cards
    end
  end
  resources :card_profiles, :except => :destroy do
    collection do
      get :matching_search
      get :export_xlsx
      get :translate
      get :current_card_profile_by_user
    end
  end

  resources :card_histories, :except => [:show, :index]
  resources :approved_jobs, :except => [:show, :update, :destroy]
  resources :card_attachments, :except => [:show, :index]

  resources :welfare_for_typhoon_reports do
    collection do
      get :field_options
      get :export
    end
  end
  resources :sign_card_reports do
    collection do
      get :field_options
      get :export
    end
  end
  resources :paid_sick_leave_award_reports do
    member do
      patch 'offer'
    end
    collection do
      get :export
      get :psla_options
      get :field_options
    end
  end
  resources :annual_work_award_reports  do
    member do
      patch 'pay'
    end
    collection do
      get :export
      get :psla_options
      get :field_options
    end
  end

  resources :borrow_times do
    member do
      patch 'return_time'
    end
    collection do
      get :field_options
      get :judge_borrow
      get :final_working_time
    end
  end


  resources :welfare_templates do
    collection do
      get :export
      post :can_create
      get :index_all
      get :like_field_options
      get :field_options
      get :department_and_position_options
      get :find_template_for_department_and_position
    end
    member do
      get :can_be_destroy
    end

  end
  resources :salary_templates do
    collection do
      get :export
      post :can_create
      get :index_all
      get :like_field_options
      get :field_options
      get :department_and_position_options
      get :find_template_for_department_and_position
      get :calculate_total
    end
    member do
      get :can_be_destroy
    end

  end

  get 'over_time_reports/index'

  get 'over_time_reports/export'

  get 'over_time_reports/field_options'

  resources :job_transfers, only: :index do
    collection do
      resources :pass_entry_trials, only: [ :create, :show ] do
        collection do
          post :can_create
        end
      end
      resources :pass_trials, only: [ :create, :show ]do
        collection do
          post :can_create
        end
      end
      resources :special_assessments, only: [ :create, :show ]

      resources :transfer_position_apply_by_departments, only: [ :create, :show ] do
        collection do
          post :can_create
        end
      end
      resources :transfer_position_apply_by_employees, only: [ :create, :show ] do
        collection do
          post :can_create
        end
      end

      resources :transfer_location_applies, only: [ :create, :show ] do
        collection do
          post :can_create
        end
      end
      resources :lent_temporarily_applies, only: [ :create, :show ] do
        collection do
          post :can_create
        end
      end

      get 'get_questionnaire_template', controller: 'assessment_questionnaire_items'
      get 'options'
      get 'export_xlsx'
    end
  end

  resources :questionnaire_templates do
    collection do
      get 'options'
    end

    member do
      get 'statistics'
      get 'instances'
      get 'export_xlsx'
      post 'release'
    end
  end

  resources :questionnaires do
    collection do
      get 'options'
    end
  end

  resources :entry_appointments do
    collection do
      get 'options'
      get 'statistics'
      get 'export_xlsx'
    end

    member do
      get 'send_content'
    end
  end

  resources :dimission_appointments do
    collection do
      get 'options'
      get 'statistics'
      get 'export_xlsx'
    end

    member do
      get 'send_content'
    end
  end

  resources :sign_card_settings, only: [ :index, :update ] do
    collection do
       get :index_by_current_user
    end
    resources :sign_card_reasons, only: [ :create, :update, :destroy]
  end

  resources :holiday_settings, only: [ :index, :create, :update, :destroy ] do
    collection do
      post 'batch_create'
    end
  end

  resources :class_settings, only: [ :index, :create, :update, :destroy ] do
    collection do
      get 'options'
      patch 'transform_code_to_new_code'
      patch 'transform_new_code_to_code'
    end
  end

  resources :typhoon_settings, only: [ :index, :create, :update, :destroy ] do
  end

  resources :typhoon_qualified_records, only: [ :index ] do
    member do
      patch 'do_apply'
      patch 'cancel_apply'
    end

    collection do
      get 'export_xlsx'
    end
  end

  resources :sign_card_records, only: [ :index, :show, :create, :update, :destroy  ] do
    member do
      get 'histories'
      post 'add_approval'
      post 'add_attach'
    end

    collection do
      get 'be_able_apply'
      get 'export_xlsx'
      get 'options'
      get :download

      get :index_for_report
      get :export_xlsx_for_report
    end

    delete 'destroy_approval/:id', to: 'sign_card_records#destroy_approval'
    delete 'destroy_attach/:id', to: 'sign_card_records#destroy_attach'
  end

  resources :overtime_records, only: [ :index, :show, :create, :update, :destroy  ] do
    collection do
      get 'options'
      get 'be_able_apply'
      get 'export_xlsx'
      get :download

      get :index_for_report
      get :export_xlsx_for_report
    end

    member do
      get 'histories'
      post 'add_approval'
      post 'add_attach'
    end

    delete 'destroy_approval/:id', to: 'overtime_records#destroy_approval'
    delete 'destroy_attach/:id', to: 'overtime_records#destroy_attach'
  end

  resources :adjust_roster_records, only: [ :index, :show, :create, :update, :destroy  ] do

    collection do
      get 'options'
      get 'report'
      get 'report_export_xlsx'
      get 'be_able_apply'
      get 'export_xlsx'
      get :download
    end
  end

  resources :working_hours_transaction_records, only: [ :index, :show, :create, :update, :destroy  ] do
    collection do
      get 'options'
      get 'be_able_apply'
      get 'export_xlsx'
      get :download
    end

    member do
      get 'histories'
      post 'add_approval'
      post 'add_attach'
    end

    delete 'destroy_approval/:id', to: 'working_hours_transaction_records#destroy_approval'
    delete 'destroy_attach/:id', to: 'working_hours_transaction_records#destroy_attach'
  end

  resources :holiday_records, only: [ :index, :show, :create, :update, :destroy  ] do
    collection do
      get 'options'
      get 'holiday_record_approval_for_employee'
      get 'holiday_record_approval_for_employee_export_xlsx'
      get 'holiday_record_approval_for_type'
      get 'holiday_record_approval_for_type_export_xlsx'
      get 'holiday_surplus_query'
      get 'holiday_surplus_query_export_xlsx'
      get 'be_able_apply'
      patch 'clear_all_surplus_snapshot'
      get 'remaining_holiday_until_date'

      get 'export_xlsx'

      get :index_for_report
      get :export_xlsx_for_report
    end

    member do
      get 'histories'
      post 'add_approval'
      post 'add_attach'
    end

    delete 'destroy_approval/:id', to: 'holiday_records#destroy_approval'
    delete 'destroy_attach/:id', to: 'holiday_records#destroy_attach'
  end

  resources :roster_lists, only: [ :index, :show, :create, :destroy  ] do
    collection do
      get 'options'
      get 'self_roster_objects'
      get 'department_roster_objects'
      get 'query_roster_objects'
      get 'query_roster_objects_export_xlsx'
      get 'is_able_apply'
      get 'fetch_roster_object'
      get 'fetch_roster_objects_of_week'
      get 'filter_options'
      get 'fetch_one_roster_object_info'
      patch 'holiday_to_general_holiday'
      post 'import_xlsx'
    end

    member do
      get 'roster_objects'
      get 'roster_objects_export_xlsx'
      patch 'to_draft'
      patch 'to_public'
      patch 'to_sealed'
      patch 'object_batch_update'
    end
  end

  resources :roster_objects, only: [] do
    resources :roster_object_logs, only: [ :index ] do
    end
  end

  resources :roster_models, only: [ :index, :create, :update, :destroy ] do
    member do
      get 'export_xlsx'
    end
    collection do
      get 'index_by_my_profile'
    end
  end

  resources :roster_preferences, only: [ :index, :show, :update ] do
    collection do
      get 'employee_roster_model_state_settings'
      get 'employee_roster_model_state_settings_export_xlsx'
      patch 'patch_intervals'
      patch 'destroy_all_intervals'
      get 'roster_model_state_setting_filter'
    end

    resources :employee_preferences, only: [ :index ] do
      member do
        patch 'set_employee_roster_preferences'
        patch 'set_employee_general_holiday_preferences'
      end
    end
  end

  resources :attends, only: [ :index ] do
    resources :attend_logs, only: [ :index ] do
      collection do
        get :index_by_current_user
        get :index_by_department
      end

    end

    collection do
      get :index_by_ids
      get 'options'
      post 'import'
      get 'all_attends'
      get 'export_xlsx'
      get :index_by_current_user
      get :index_by_department
    end
  end

  resources :attend_month_approvals, only: [ :index, :create ] do
    collection do
      get 'options'
      get 'is_apply_record_compensate'
      get 'export_xlsx'
      patch 'patch_approval_time'
    end

    member do
      patch 'approval'
      patch 'cancel_approval'
    end
  end

  resources :attend_monthly_reports, only: [ :index ] do
    collection do
      post 'create_fake_data_reports'
      get 'export_xlsx'
      get :options
    end
  end

  resources :attend_annual_reports, only: [ :index ] do
    collection do
      get 'export_xlsx'
      get :options
    end
  end

  resources :compensate_reports, only: [ :index ] do
    member do
      get 'options'
    end

    collection do
      get :header_options
      get 'export_xlsx'
      get 'all_info'
    end
  end

  resources :annual_attend_reports, only: [ :index ] do
    collection do
      get 'options'
      get 'export_xlsx'
    end
  end

  resources :paid_sick_leave_reports, only: [ :create ] do
    collection do
      patch 'release'
      patch 'remove'
    end
  end

  resources :paid_sick_leave_report_items, only: [ :index ] do
    collection do
      get 'options'
      get 'export_xlsx'
    end
  end

  resources :roster_model_states, only: [ :index, :create, :update, :destroy ] do
    collection do
      # get 'histories'
      get 'user_roster_models_info'

      patch 'update_is_current_for_all'

      get 'be_able_apply'
      get 'roster_model_weeks_count'
    end
  end

  resources :punch_card_states, only: [ :update ] do
    collection do
      get 'histories'
      get 'report'
      get 'options'
      get 'report_export_xlsx'

      patch 'update_is_current_for_all'
    end
  end

  resources :shift_status, only: [ :update ] do
  end


  resources :training_papers do
    collection do
      get 'index_by_mine'
      get 'index_by_department'
      get 'options'
      get 'export_xlsx'
    end

    member do
      patch 'update_questionnaire'
      patch 'upload_file'
    end
  end

  resources :student_evaluations do
    collection do
      get 'index_by_mine'
      get 'index_by_department'
      get 'options'
      get 'export_xlsx'
    end

    member do
      patch 'update_questionnaire'
    end
  end

  resources :supervisor_assessments do
    collection do
      get 'index_by_mine'
      get 'index_by_department'
      get 'options'
      get 'export_xlsx'
    end

    member do
      patch 'update_questionnaire'
    end
  end

  resources :json_web_token

  resources :roles do
    member do
      get :permissions
      post :add_permission
      delete :remove_permission
      get :users
      post :add_user
      delete :remove_user
    end

    collection do
      get :mine
    end
  end

  # resources :permissions do
  # end
  get "policies" => "permissions#policies"

  resources :users do
    member do
      get :roles
      post :add_role
      post :remove_role
      get :permissions
      get :holiday_info, to: 'profiles#holiday_info'
    end
    collection do
      get :get_user_group_by_position_id
    end

    resources :my_attachments do
      collection do
        get :head_index
        get :all_index
      end
    end
    resource :profit_conflict_information, only: [:show, :update]
    resource :family_member_information, only: [:show, :update]
    resource :language_skill, only: [:show, :update]
    resource :background_declaration, only: [:show, :update]
  end


  resources :my_attachments, only: :destroy do
    member do
      get :download
    end
  end


  resources :trains do
    member do
      get :introduction
      get :introduction_by_current_user
      get :train_classes
      get :train_classes_by_current_user
      get :classes
      get :titles
      get :online_materials
      get :online_materials_by_current_user
      get :entry_lists
      get :entry_lists_by_current_user
      get :final_lists
      get :final_lists_by_current_user
      post :entry_lists, to: 'trains#create_entry_lists'
      get :sign_lists
      get :sign_lists_by_current_user
      patch :cancel
      get :result
      get :result_by_current_user
      get 'entry_lists/field_options', to: 'trains#entry_lists_field_options'
      get 'entry_lists/field_columns', to: 'trains#entry_lists_field_columns'
      get :result_index
      get :result_index_by_current_user
      get 'result_index/field_options', to: 'trains#result_index_field_options'
      get 'result_index/field_columns', to: 'trains#result_index_field_columns'
      patch :entry_lists, to: 'trains#batch_update_entry_lists'

      get 'sign_lists/field_options', to: 'trains#sign_lists_field_options'
      get 'sign_lists/field_columns', to: 'trains#sign_lists_field_columns'
      get 'final_lists/field_options', to: 'trains#final_lists_field_options'
      get 'final_lists/field_columns', to: 'trains#final_lists_field_columns'

      patch :has_been_published
      patch :training
      patch :completed
      patch :cancelled

      patch :update_result_evaluation
      get :result_evaluation
      get :result_evaluation_by_current_user
      get :trains_info_by_user, to: 'trains#trains_info_by_user'

      patch :create_training_papers
      patch :create_student_evaluations
      patch :create_supervisor_assessment

      get :get_training_absentees_status, to: 'trains#get_training_absentees_status'

      get :entry_lists_with_to_confirm

    end

    collection do
      get :options_for_create_train
      get :field_options
      get :options
      get :columns
      get :all_trains
      get :field_options_by_all_trains
      get :get_user
      get :field_options_by_get_user
      get :records_by_departments
      get :field_options_by_all_records
      get :final_lists
      get :all_records
      get :columns_by_all_trains
      get :columns_by_all_records
      get :columns_by_records_by_departments
    end
  end

  resources :profiles do
    resource :medical_information, only: [:show, :update]

    resource :suncity_charity, only: [:show, :update]

    resource :provident_fund, only: [:create, :show, :update] do
      patch :update_from_profile
      get :can_create
    end

    resource :love_fund, only: [:update, :show] do
      patch :update_from_profile
      get :can_create
    end

    resource :medical_insurance_participator, only: [:update, :show] do
      patch :update_from_profile
      get :can_create
    end



    collection do
      get :check_l_p_d
      get :template
      get :advance_search_params_check
      get :export_xlsx
      get :emails_for_autocomplete
      get :autocomplete
      get :autocomplete_employees
      get :attachment_missing
      get :attachment_missing_export
      get :query_applicant_profile_id_card_number
      get :select_welfare_template
      get :my_avatar
      get :index_by_department
    end


    member do
      get :head_title
      post :attachment_missing_sms_sent
    end

    resources :profile_attachments do
      member do
        get :preview
        get :download
      end
    end

    resources :contract_informations do
      member do
        get :preview
        get :download
      end
    end

    resources :family_declaration_items do
      collection do
        get :index_by_user
        delete :destory_when_false
      end
    end

    resources :education_informations, except: [:index] do
      collection do
        get :index_by_user
      end
    end


    resources :work_experences, except: [:index] do
      collection do
        get :index_by_user
      end
    end

    resources :professional_qualifications, only: [:create] do
      collection do
        get :index_by_user
      end
    end

  end

  resources :select_column_templates do
    collection do
      get :all_selectable_columns
      get :all_selectable_columns_with_section
      get :index_by_department
      post :create_by_department
    end
  end

  resources :applicant_select_column_templates do
    collection do
      get :all_selectable_columns
      get :all_selectable_columns_with_section
    end
  end

  resources :applicant_profiles do
    collection do
      get :template
      get :export_xlsx
      get :export_xlsx_with_apply_source_apply_date_apply_status
      get :advance_search_params_check
    end

    member do
      get :same_id_card_number_profiles
    end

    resources :applicant_attachments do
      member do
        get :download
        get :preview
      end
    end
  end

  resources :locations do
    collection do
      get :location_children
      get :location_children_with_parent
      get :tree
      get :with_departments
      get :all_locations
    end
  end

  resources :departments do
    member do
      patch :enable
      patch :disable
      get :profiles
      get :positions
      get :train_entry_lists, to: 'trains#train_entry_lists'
    end

    collection do
      get :with_positions
      get :tree
      get :index_with_Pending
    end

    scope module: 'department' do
      resources :rosters, only: :index
    end

  end

  resources :positions do
    member do
      patch :enable
      patch :disable
    end

    collection do
      get :tree
      get :position_with_department
    end
  end

  resources :profile_attachment_types
  resources :applicant_attachment_types

  resources :attachments do
    collection do
      post :upload_avatar
    end

    member do
      get :preview
      get :download
    end
  end

  get 'avatar/:seaweed_hash' => "attachments#avatar"

  resources :jobs do
    collection do
      get :statuses
      get :statistics
      get :enabled
      get :jobs_with_pending
    end
  end

  resources :applicant_positions do
    member do
      patch :update_status
      patch :create_empoid
    end

    collection do
      get :statuses
      get :summary
    end

    resources :audiences do
      collection do
        get :statuses
      end
    end

    resources :interviews do
      collection do
        get :index_by_current_user
      end

      member do
        get :interviewers
        patch :add_interviewers
        patch :remove_interviewers
      end
    end

    resources :contracts do
    end

    resources :application_logs do
    end

    resources :agreement_files, controller: :applicant_position_agreement_files do
      member do
        get :download
      end
      collection do
        post :generate
      end
    end

  end

  get 'agreement_files/file_list' => "applicant_position_agreement_files#file_list"
  get 'contracts/statuses' => "contracts#statuses"
  get 'application_logs/types' => "application_logs#types"
  get 'audiences/statuses' => "audiences#statuses"
  get 'audiences/mine' => "audiences#mine"

  resources :interviewers do
    collection do
      get :mine
      get :waiting_for_choose
      get :waiting_for_interview
      get :statuses
    end
    member do
      patch :update_status
    end
  end

  resources :contract_agreements do
    member do
      get :download
    end
  end

  resources :messages do
    collection do
      get :unread_messages
      get :unread_messages_count
      patch :read_all
    end

    member do
      patch :read
    end
  end

  resources :sms do
    collection do
      patch :templates
      patch :delivery
      post :delivery_sms
    end
  end

  resources :email do
    collection do
      get :types
      get :templates
      patch :delivery
      post :delivery_email
    end
  end

  post 'send_email/:email_type' => "email#delivery"

  resources :rosters do
    member do
      get :employees
    end
    collection do
      scope module: 'roster' do
        resources :available_departments, only: [:index]
      end
      get 'show_by_single_month', controller: 'rosters'
      get 'show_by_date', controller: 'rosters'
      get 'disable_departments', controller: 'rosters'
      get 'get_period', controller: 'rosters'
      get 'get_loc_dept_with_emplc_group', controller: 'rosters'
    end


    scope module: 'roster' do
      get 'items_for_week', controller: 'items', on: :collection
      get 'item_for_date', controller: 'items', on: :collection
      resources :interval_settings, only: [:update]
      resources :days, only: [:index]
      resources :setting_emptys, only: [:create]
      resources :rostering, only: [:create]
      resources :items, only: [:index, :update, :create], defaults: { format: :json } do
        get 'field_options', on: :collection
        resources :roster_item_logs, only: [:index]
      end
      resources :adopt_ultimo_settings, only: [:create]
      resources :batch_item_updates, only: [:create]
      resources :settings, only: [:index, :create]
    end

    resources :shifts do
    end

    resources :shift_employee_count_settings do
      member do

      end
      collection do
        patch :batch_update
        patch :set_by_wday
        patch :set_by_daterange
      end
    end

    resources :shift_groups do
      member do
        patch :add_users
        patch :remove_users
      end
    end

    resources :shift_user_settings do
      member do
        patch :add_shifts
        patch :remove_shifts
        patch :add_shift_special
        patch :remove_shift_special
        patch :update_shift_special_item

        patch :add_rests
        patch :remove_rests
        patch :add_rest_special
        patch :remove_rest_special
        patch :update_rest_special_item

        patch :empty_settings
        patch :dup_from_previous
      end
    end
  end

  resources :shift_employee_count_settings do
    collection do
      get :grade_tags
    end
  end

  resources :attendances do
    resources :attendance_items, only: [:index, :show] do
      collection do
        get :export
        post :import
      end

      resources :attendance_item_logs, only: [:index]
    end

    collection do
      get 'get_period', controller: 'attendances'
      get 'find_attendance_item', controller: 'attendance_items'
    end
  end

  resources :over_times do
    collection do
      get :field_options
      get :get_shift_and_attendance_by_date
    end
  end

  get 'holidays/field_options'
  get 'holidays/get_holiday_days'
  get 'holidays/get_holiday_item_list'
  resources :holidays
  get 'public_holidays/find_over_lap'
  resources :public_holidays
  get 'holiday_reports/index'
  get 'holiday_reports/field_options'
  get 'holiday_reports/export'
  get 'holidays_approve/table_header'
  get 'holidays_approve/index'
  get 'holidays_approve/field_options'
  get 'holidays_approve/export'
  get 'holidays_remaining/table_header'
  get 'holidays_remaining/index'
  get 'holidays_remaining/export'
  get 'holidays_remaining/field_options'
  resources :holiday_switches do
    collection do
      get :field_options
    end
  end

  resources :absenteeisms do
    collection do
      get :field_options
    end
  end

  resources :immediate_leave do
    collection do
      get :field_options
    end
  end

  resources :attendance_states
  resources :revise_clocks do
    collection do
      get :field_options
    end
  end

  resources :select_options

  resources :punch_logs

  resources :shift_states, only: [:show, :create, :update]

  mount ActionCable.server => '/cable'

  resources :exception_logs do
    collection do
      delete :all
    end
  end
end
