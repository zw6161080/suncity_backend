module JobTransferAble

  extend ActiveSupport::Concern

  included do
    def create_lent_temporarily_items(lent_temporarily_items, current_user, lent_keys)
      lent_temporarily_items.each do |lent_temporarily_item|
        self.lent_temporarily_items.create(lent_temporarily_item.permit(:region,
                                                                         :user_id,
                                                                         :lent_date,
                                                                         :return_date,
                                                                         :lent_location_id,
                                                                         :lent_salary_calculation,
                                                                         :return_salary_calculation,
                                                                         :comment))
        lent_temporarily_item['deployment_type'] = 'lent'
        lent_temporarily_item['lent_begin'] = lent_temporarily_item['lent_date']
        lent_temporarily_item['lent_end'] = lent_temporarily_item['return_date']
        lent_temporarily_item['temporary_stadium_id'] = lent_temporarily_item['lent_location_id']

        lent_temporarily_item['calculation_of_borrowing'] = lent_temporarily_item['lent_salary_calculation']
        lent_temporarily_item['return_compensation_calculation'] = lent_temporarily_item['return_salary_calculation']
        lent_temporarily_item['temporary_stadium'] = lent_temporarily_item['lent_location_id']
        lent_temporarily_item['salary_calculation'] = lent_temporarily_item['calculation_of_borrowing']
        user = User.find(lent_temporarily_item['user_id'])

        # For roster_object
        if lent_temporarily_item['lent_begin'] && lent_temporarily_item['lent_end']

          start_date = lent_temporarily_item['lent_begin'].in_time_zone.to_date
          end_date = lent_temporarily_item['lent_end'].in_time_zone.to_date

          (start_date .. end_date).each do |d|
            ro = RosterObject.where(user_id: user.id, is_active: ['active', nil], roster_date: d).first
            if ro
              RosterObject.create(ro.attributes.merge({
                                                        id: nil,
                                                        is_active: 'inactive',
                                                        special_type: 'lent_temporarily',
                                                        created_at: nil,
                                                        updated_at: nil
                                                      }))

              ro.is_active = 'active'
              ro.special_type = 'lent_temporarily'
              ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
              ro.location_id = lent_temporarily_item['lent_location_id']
              # ro.roster_list_id = nil
              ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
              ro.save

              ro.roster_object_logs.create(modified_reason: 'lent_temporarily',
                                           approver_id: current_user.id,
                                           approval_time: Time.zone.now.to_datetime,
                                           class_setting_id: ro.class_setting_id,
                                           is_general_holiday: ro.is_general_holiday,
                                           working_time: ro.working_time,
                                           holiday_type: ro.holiday_type,
                                           borrow_return_type: ro.borrow_return_type,
                                           working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
              )
            else
              d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
              o_location = ProfileService.location(user, d_time)
              o_department = ProfileService.department(user, d_time)

              inactive_ro = RosterObject.create(user_id: user.id,
                                                roster_date: d,
                                                location_id: o_location.id,
                                                department_id: o_department.id,
                                                is_active: 'inactive',
                                                special_type: 'lent_temporarily') if o_location && o_department

              active_ro = RosterObject.create(user_id: user.id,
                                              roster_date: d,
                                              location_id: lent_temporarily_item['lent_location_id'],
                                              department_id: o_department.id,
                                              is_active: 'active',
                                              special_type: 'lent_temporarily') if o_department

              active_ro.roster_object_logs.create(modified_reason: 'lent_temporarily',
                                                  approver_id: current_user.id,
                                                  approval_time: Time.zone.now.to_datetime,
                                                  class_setting_id: active_ro.class_setting_id,
                                                  is_general_holiday: active_ro.is_general_holiday,
                                                  working_time: active_ro.working_time,
                                                  holiday_type: active_ro.holiday_type,
                                                  borrow_return_type: active_ro.borrow_return_type,
                                                  working_hours_transaction_record_id: active_ro.working_hours_transaction_record_id,
              ) if active_ro
            end
          end
        end

        # should_change_roster_objects = RosterObject
        #                                  .where(user_id: user.id, is_active: ['active', nil])
        #                                  .where("roster_date >= ? AND roster_date <= ?", lent_temporarily_item['lent_begin'], lent_temporarily_item['lent_end'])

        # should_change_roster_objects.each do |ro|
        #   RosterObject.create(ro.attributes.merge({
        #                                             id: nil,
        #                                             is_active: 'inactive',
        #                                             special_type: 'lent_temporarily',
        #                                             created_at: nil,
        #                                             updated_at: nil
        #                                           }))

        #   ro.is_active = 'active'
        #   ro.special_type = 'lent_temporarily'
        #   ro.class_setting_id = nil
        #   ro.location_id = lent_temporarily_item['lent_location_id']
        #   ro.roster_list_id = nil
        #   ro.save

        #   ro.roster_object_logs.create(modified_reason: 'lent_temporarily',
        #                                approver_id: current_user.id,
        #                                approval_time: Time.zone.now.to_datetime)
        # end

        self.create_job_transfer(user, current_user, lent_temporarily_item.permit(lent_keys),
                                 salary_calculation: lent_temporarily_item['salary_calculation'],
                                 transfer_type: "lent_temporarily",
                                 apply_result: true,
                                 write_new_lent_to_jt: true
                                )
        raise '不符合创建规则' unless TimelineRecordService.can_lent_record_create(lent_temporarily_item.permit( lent_keys).merge(
          original_hall_id: user['location_id']
        ))
        LentRecord.create!(lent_temporarily_item.permit( lent_keys).merge(
                             original_hall_id: user['location_id']
                           ))
      end
    end

    def create_transfer_location_items(transfer_location_applies, current_user, museum_keys)
      transfer_location_applies.each do |transfer_location_item|
        self.transfer_location_items.create(transfer_location_item.permit(:region, :user_id, :transfer_date, :transfer_location_id, :salary_calculation, :comment))
        new_row = transfer_location_item
                    .with_indifferent_access
        transfer_location_item[:date_of_employment] = transfer_location_item[:transfer_date]
        transfer_location_item[:deployment_type] = 'museum'
        transfer_location_item[:location_id] = transfer_location_item[:transfer_location_id]
        transfer_location_item[:salary_calculation] = transfer_location_item[:salary_calculation]
        user = User.find(new_row['user_id'])

        should_change_roster_objects = RosterObject
                                         .where(user_id: user.id, is_active: ['active', nil])
                                         .where("roster_date >= ?", transfer_location_item[:transfer_date])
        should_change_roster_objects.each do |ro|
          RosterObject.create(ro.attributes.merge({
                                                    id: nil,
                                                    is_active: 'inactive',
                                                    special_type: 'transfer_location',
                                                    created_at: nil,
                                                    updated_at: nil
                                                  }))
          ro.is_active = 'active'
          ro.special_type = 'transfer_location'
          ro.class_setting_id = nil
          ro.location_id = transfer_location_item[:transfer_location_id]
          # ro.roster_list_id = nil
          ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
          ro.save

          ro.roster_object_logs.create(modified_reason: 'transfer_location',
                                       approver_id: current_user.id,
                                       approval_time: Time.zone.now.to_datetime,
                                       class_setting_id: ro.class_setting_id,
                                       is_general_holiday: ro.is_general_holiday,
                                       working_time: ro.working_time,
                                       holiday_type: ro.holiday_type,
                                       borrow_return_type: ro.borrow_return_type,
                                       working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
                                      )
        end
        self.create_job_transfer(user, current_user, transfer_location_item.permit(museum_keys),
                                 salary_calculation: new_row['salary_calculation'],
                                 transfer_type: "transfer_location_apply",
                                 apply_result: true,
                                 write_new_museum_to_jt: true
                                )
        rails '不符合创建规则' unless TimelineRecordService.can_museum_record_create(transfer_location_item.permit(museum_keys))
        MuseumRecord.create!(transfer_location_item.permit(museum_keys))
      end if transfer_location_applies
    end

    def create_training_courses(training_courses)
      training_courses.each do |training_course|
        self.training_courses.create(training_course.permit(:region, :user_id, :chinese_name, :english_name, :simple_chinese_name, :explanation))
      end if training_courses
    end

    def create_approval_items(approval_items)
      approval_items.each do |approval_item|
        self.approval_items.create(approval_item.permit(:user_id, :datetime, :comment))
      end if approval_items
    end

    def create_attend_attachments(attend_attachments, current_user)
      attend_attachments.each do |attend_attachment|
        self.attend_attachments.create(attend_attachment.permit(:file_name, :comment, :attachment_id).merge({creator_id: current_user.id}))
      end if attend_attachments
    end

    def create_questionnaire_items(user, assessment_questionnaire, questionnaire_items, region)
      option_items = user.grade > 4 ? AssessmentQuestionnaireItem.grade_five_options_template : AssessmentQuestionnaireItem.under_five_options_template
      all_items = option_items + AssessmentQuestionnaireItem.normal_options_template
      all_items.each do |item_info|
        questionnaire_items = questionnaire_items ? questionnaire_items : []
        questionnaire_item = questionnaire_items.select { |q_item| q_item[:order_no] == item_info[:order_no] }.first

        assessment_questionnaire.items.create!(
          region: region,
          chinese_name: item_info[:chinese_name],
          english_name: item_info[:english_name],
          simple_chinese_name: item_info[:simple_chinese_name],
          group_chinese_name: item_info[:group_chinese_name],
          group_english_name: item_info[:group_english_name],
          group_simple_chinese_name: item_info[:group_simple_chinese_name],
          order_no: item_info[:order_no],
          score: questionnaire_item ? questionnaire_item[:score] : nil,
          explain: questionnaire_item ? questionnaire_item[:explain] : nil
        )
      end
    end

    def save_salary_record(user)
      sr = user.salary_records.by_current_valid_record_for_salary_info.first
      self.update(salary_record: ActiveModelSerializers::SerializableResource.new(sr, adapter: :attributes).as_json) if sr
    end

    def save_welfare_record(user)
      wr = user.welfare_records.by_current_valid_record_for_welfare_info.first
      self.update(welfare_record: ActiveModelSerializers::SerializableResource.new(wr, adapter: :attributes).as_json) if wr
    end

    def save_new_salary_record(sr)
      self.update(new_salary_record: ActiveModelSerializers::SerializableResource.new(sr, adapter: :attributes).as_json) if sr
    end

    def save_new_welfare_record(wr)
      self.update(new_welfare_record: ActiveModelSerializers::SerializableResource.new(wr, adapter: :attributes).as_json) if wr
    end

    def create_job_transfer(user,current_user,new_career,options)
      jt = self.job_transfers.build
      jt.region = self.region
      jt.apply_date = self.apply_date
      jt.user_id = user.id
      jt.inputter_id = current_user.id
      jt.input_date = self.created_at
      jt.transfer_type = options[:transfer_type]


      jt.original_location_id = user['location_id']
      jt.original_department_id = user['department_id']
      jt.original_position_id = user['position_id']
      jt.original_company_name = user['company_name']
      jt.original_employment_status = user['employment_status']

      jt.original_grade = user['grade']
      jt.comment = self.comment
      jt.apply_result = options[:apply_result]

      if options[:write_new_career_to_jt]
        jt.position_start_date = new_career['career_begin']
        jt.position_end_date = new_career['career_end']
        jt.trial_expiration_date = new_career['trial_period_expiration_date']
        jt.new_company_name = new_career['company_name']
        jt.new_employment_status = new_career['employment_status']
        jt.new_location_id = new_career['location_id']
        jt.new_department_id = new_career['department_id']
        jt.new_position_id = new_career['position_id']
        jt.new_grade = new_career['grade']
        jt.instructions = new_career['deployment_instructions']
      end
      if options[:write_new_lent_to_jt]
        jt.position_start_date = new_career['lent_begin']
        jt.position_end_date = new_career['lent_end']
        jt.trial_expiration_date = nil
        jt.new_company_name = user.company_name
        jt.new_employment_status = user.employment_status
        jt.new_location_id = new_career['temporary_stadium_id']
        jt.new_department_id = user.department_id
        jt.new_position_id = user.position_id
        jt.new_grade = user.grade
        jt.instructions = new_career['deployment_instructions']
      end
      if  options[:write_new_museum_to_jt]
        jt.position_start_date = new_career['date_of_employment']
        jt.position_end_date = nil
        jt.trial_expiration_date = nil
        jt.new_company_name = user.company_name
        jt.new_employment_status = user.employment_status
        jt.new_location_id = new_career['location_id']
        jt.new_department_id = user.department_id
        jt.new_position_id = user.position_id
        jt.new_grade = user.grade
        jt.instructions = new_career['deployment_instructions']
      end


      jt.salary_calculation = options[:salary_calculation]
      jt.save!
    end



  end
end
