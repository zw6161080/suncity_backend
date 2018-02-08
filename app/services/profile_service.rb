# coding: utf-8
class ProfileService
  class << self

    # 职称信息
    def get_previous_record(records, target_from, column_key)

    end

    def get_after_record(records, target_from, column_key)

    end
    #获取员工最新的福利记录
    def current_welfare_record(user, year_month = Time.zone.now.beginning_of_day)
      user.welfare_records.by_search_for_one_day(year_month).first
    end

    #获取员工的双粮情况
    def double_pay(user, year_month = Time.zone.now.beginning_of_day)
      ActiveModelSerializers::SerializableResource.new(current_welfare_record(user, year_month)).serializer_instance.double_pay
    end

    #获取员工最新的离职记录
    def current_resignation_record(user)
      user.resignation_records.order(resigned_date: :desc).first
    end

    #获取员工的离职通知日期
    def notice_date(user)
      current_resignation_record(user)&.notice_date
    end

    #获取员工的最后工作日期
    def final_work_date(user)
      current_resignation_record(user)&.final_work_date
    end
    #员工是否补偿年资
    def compensation_year(user)
      current_resignation_record(user)&.compensation_year
    end

    #是否豁免离职通知期
    def notice_period_compensation(user)
      current_resignation_record(user)&.notice_period_compensation
    end

    #是否再聘用此人
    def is_in_whitelist(user)
      current_resignation_record(user)&.is_in_whitelist
    end

    #员工离职类型
    def resigned_reason(user)
      current_resignation_record(user)&.resigned_reason
    end

    #离职原因
    def reason_for_resignation(user)
      current_resignation_record(user)&.reason_for_resignation
    end

    #获取当前的报政府职位名称
    def position_of_govt_record(user)
      user.card_profile&.approved_job_name
    end

    #确认(当前/某一天）员工所在组别
    def group(user, year_month_day = Time.zone.now.beginning_of_day )
      user.career_records.where('valid_date <= :year_month_day AND (invalid_date >= :year_month_day OR invalid_date IS NULL )', year_month_day: year_month_day).order(valid_date: :desc, created_at: :desc).first&.group
    end

    #获取员工入职日期
    def date_of_employment(user)
      if !user.career_records.where(deployment_type: :entry).empty?
        user.career_records.where(deployment_type: :entry).order(career_begin: :asc).first&.career_begin
      else
        user.career_records.order(career_begin: :asc).first&.career_begin
      end
    end

    #确认(当前/某一天）员工所在部门
    def department(user, year_month_day = Time.zone.now.beginning_of_day )
      user.career_records.where('valid_date <= :year_month_day AND (invalid_date >= :year_month_day OR invalid_date IS NULL )', year_month_day: year_month_day).order(career_begin: :desc, created_at: :desc).first&.department
    end

    #确认(当前/某一天）员工所在职位
    def position(user, year_month_day = Time.zone.now.beginning_of_day )
      user.career_records.where('valid_date <= :year_month_day AND (invalid_date >= :year_month_day OR invalid_date IS NULL )', year_month_day: year_month_day).order(valid_date: :desc, created_at: :desc).first&.position
    end

    #确认(当前/某一天）员工公司名称
    def company_name(user, year_month_day = Time.zone.now.beginning_of_day )
      user.career_records.where('valid_date <= :year_month_day AND (invalid_date >= :year_month_day OR invalid_date IS NULL )', year_month_day: year_month_day).order(valid_date: :desc, created_at: :desc).first&.company_name
    end

    #确认(当前/某一天）员工职级
    def grade(user, year_month_day = Time.zone.now.beginning_of_day )
      user.career_records.where('valid_date <= :year_month_day AND (invalid_date >= :year_month_day OR invalid_date IS NULL )', year_month_day: year_month_day).order(valid_date: :desc, created_at: :desc).first&.grade
    end
    #确认(当前/某一天）员工归属类别
    def division_of_job(user, year_month_day = Time.zone.now.beginning_of_day )
      user.career_records.where('valid_date <= :year_month_day AND (invalid_date >= :year_month_day OR invalid_date IS NULL )', year_month_day: year_month_day).order(valid_date: :desc, created_at: :desc).first&.division_of_job
    end

    #确认(当前/某一天）员工在职类别
    def employment_status(user, year_month_day = Time.zone.now.beginning_of_day )
      user.career_records.where('valid_date <= :year_month_day AND (invalid_date >= :year_month_day OR invalid_date IS NULL )', year_month_day: year_month_day).order(valid_date: :desc, created_at: :desc).first&.employment_status
    end


    #获取当前的部门的id
    def  department_id(user, year_month_day = Time.zone.now.beginning_of_day )
      department(user, year_month_day)&.id
    end

    #获取当前的职位的id
    def  position_id(user, year_month_day = Time.zone.now.beginning_of_day )
      position(user, year_month_day)&.id
    end

    def group_id(user, year_month_day = Time.zone.now.beginning_of_day)
      group(user, year_month_day)
    end



    #确认(当前/某一天）员工所在场馆
    def location(user, year_month_day = Time.zone.now.beginning_of_day)
      career_record = user.career_records.where('valid_date <= :year_month_day AND (invalid_date >= :year_month_day OR invalid_date IS NULL )', year_month_day: year_month_day).first
      unless career_record
        return nil
      end
      #与职程信息关联的调馆信息并在当天生效
      museum_record = career_record.museum_records.where("date_of_employment <= :year_month_day", year_month_day: year_month_day).order(date_of_employment: :desc).first
      #与职程信息关联的暂借信息并在当天生效
      lent_record = career_record.lent_records.where("lent_begin <= :year_month_day AND (lent_end >= :year_month_day OR lent_end is null)", year_month_day: year_month_day).order(lent_begin: :desc).first
      last_record = [lent_record,  museum_record].compact.sort_by! do |record|
        if record.is_a? LentRecord
          record.lent_begin
        elsif record.is_a? MuseumRecord
          record.date_of_employment
        end
      end.last
      if last_record
        if last_record.is_a? LentRecord
          last_record.temporary_stadium
        else
          last_record.location
        end
      else
        career_record.location
      end
    end

    def location_id(user, year_month_day = Time.zone.now.beginning_of_day)
      location(user, year_month_day)&.id
    end



    def can_create_love_fund?(user, join_date)
      date_of_employment  = date_of_employment(user)
      join_date > date_of_employment(user) if date_of_employment
    end

    def can_create_provident_fund?(user, join_date)
      date_of_employment  = date_of_employment(user)
      join_date > date_of_employment(user) if date_of_employment
    end

    def can_create_medical_insurance_participator?(user, join_date)
      date_of_employment  = date_of_employment(user)
      join_date > date_of_employment(user) if date_of_employment
    end

    # 职称信息新建前的时间校验
    def career_can_create?(user, target_from, target_to)
      records = user.career_records.order(:career_begin => :desc)
      # 获取前后记录
      before_target = records.where('career_begin < :from', from: target_from).order(:career_begin => :desc).last
      after_target = records.where('career_begin > :to', to: target_from).order(:career_begin => :desc).first
      if before_target && after_target

      end
      true
    end

    #员工是否确认离职，并离职日期已到
    def is_leave?(user)
      ids = ResignationRecord.all.where(status: :being_valid, time_arrive: :arrived).select(:user_id).map(&:user_id)
      if ids.include? user&.id
        true
      else
        false
      end
    end
    #员工是否确认离职
    def to_be_leaving?(user)
      user.resignation_records.count > 0
    end

    def employees_left_this_month(year_month)
      ResignationRecord.where(
        "status = 'being_valid' AND  time_arrive = 'arrived' AND resigned_date >= :year_month_begin AND
        resigned_date <= :year_month_end", year_month_begin: year_month.beginning_of_month,
        year_month_end: year_month.end_of_month).select(:user_id).map(&:user_id)
    end

    def employees_left_before_this_month(year_month)
      ResignationRecord.where(
        "status = 'being_valid' AND time_arrive = 'arrived' AND
        resigned_date < :year_month_begin ", year_month_begin: year_month.beginning_of_month).select(:user_id).map(&:user_id)
    end

    def employees_left_last_day_this_month(year_month)
      ResignationRecord.where(
        "status = 'being_valid' AND  time_arrive = 'arrived' AND resigned_date >= :last_day_begin AND
        resigned_date <= :year_month_end", last_day_begin: year_month.end_of_month - 1.day,
        year_month_end: year_month.end_of_month).select(:user_id).map(&:user_id)
    end

    def float_salary_month_entries_users(year_month)
      User.where(id: self.users1(year_month).ids - self.users2(year_month).ids)
    end

    #users1: 月末前所有员工
    def users1(year_month)
      ids = User.all.select{|user|
        user.career_entry_date < year_month.end_of_month rescue false
      }.map{|user|
        user.id
      }
      User.where(id: ids)
    end

    #users2: 月初前所有离职员工
    def users2(year_month)
      User.where(id: self.employees_left_before_this_month(year_month))
    end

    #users3: 这个月离职员工
    def users3(year_month)
      User.where(id: self.employees_left_this_month(year_month))
    end

    #users4: 在职员工
    def users4(year_month)
      User.where(id: self.users1(year_month).ids - self.users2(year_month).ids - self.users3(year_month).ids)
    end

    #users5: 这个月最后一天离职的员工
    def users5(year_month)
      User.where(id: self.employees_left_last_day_this_month(year_month))
    end

    #users6: 今年在职的员工
    def users6(year_month)
      User.where(id: self.users1(year_month.end_of_year).ids - self.users2(year_month.beginning_of_year).ids)
    end

    #users7: 在职员工和最后一天离职的员工
    def users7(year_month)
      User.where(id: self.users4(year_month.end_of_year).ids + self.users5(year_month.beginning_of_year).ids)
    end


    #筛选出该月有公积金的员工
    def has_provident_fund_this_month(users, year_month)
      User.where(id: users.select{|user| has_provident_fund_this_month_by_user?(user, year_month)}.map{|user| user.id})
    end
    # 该月员工是否有公积金
    def has_provident_fund_this_month_by_user?(user, year_month)
      pf = ProvidentFund.where(user_id: user.id).first
      pf ? pf.participation_date.to_datetime <= year_month.end_of_month : false rescue false
    end

    #是否当月入职
    def is_join_in_this_month(user, month_begin)
      career_begin =  user.career_records.order(career_begin: :asc).first.career_begin rescue false
      if career_begin
        career_begin  >= month_begin  && career_begin  <= month_begin.end_of_month
      else
        career_begin
      end
    end

    #入职日期
    def employment_of_date(user)
      date_of_employment(user) rescue Time.zone.now
    end
    #是否当月离职
    def is_leave_in_this_month(user, month_begin)
      # resigned_date = ResignationRecord.where(user_id: user.id).order(created_at: :desc).first&.resigned_date
      resigned_date = user.resignation_records.order(resigned_date: :desc).first&.resigned_date
      if !!resigned_date
        resigned_date >= month_begin && resigned_date <= month_begin.end_of_month
      else
        false
      end
    end
    #离职日期
    def resigned_date(user, resignation_record_id = nil)
      if resignation_record_id
        ResignationRecord.where(user_id: user.id, id: resignation_record_id).order(created_at: :desc).first&.resigned_date
      else
        user.resignation_records.order(resigned_date: :desc).first&.resigned_date
      end
    end

    #身份证号
    def id_number(user)
      user.profile.data['personal_information']['field_values']['id_number']
    end

    #社会保账号
    def sss_number(user)
      user.profile.data['personal_information']['field_values']['sss_number']
    end

    #税务编号
    def tax_number(user)
      user.profile.data['personal_information']['field_values']['tax_number']
    end



    def get_year_month_end(year_month)
      if year_month.nil?
        Time.zone.now.end_of_month
      else
        year_month.end_of_month
      end
    end


    #是否存在蓝卡档案
    def has_blue_card(user, year_month = nil)
      year_month_end = get_year_month_end(year_month)

      data_for_calc = if to_be_leaving?(user)
         resigned_date = resigned_date(user)
        if resigned_date > year_month_end
          year_month_end
        else
          resigned_date
        end
      else
        year_month_end
      end
      user.card_profile&.date_to_submit_fingermold && user.card_profile.date_to_submit_fingermold.beginning_of_day <= data_for_calc
    end
    #存在蓝卡且未取消蓝卡
    def not_cancel_blue_card(user, year_month = nil)
      if has_blue_card(user, year_month)
        year_month_end = get_year_month_end(year_month)
        if CardProfile.where(user_id: user.id).first&.cancel_date.nil?
          true
        else
          CardProfile.where(user_id: user.id).first&.cancel_date.to_datetime.beginning_of_day > year_month_end.end_of_day
        end
      else
        false
      end
    end
    #存在蓝卡
    #未取消并
    #该月蓝卡有效
    def not_cancel_blue_card_this_month(user, year_month)
      not_cancel_blue_card(user,year_month)
    end

    # 判断是否为外地雇员
    def whether_foreign_employee(user)
      %w(profession non-profession).include? user.profile.data['position_information']['field_values']['local_or_foreign']
    end

    #出粮方式
    def payment_method(user)
      user.profile.data['position_information']['field_values']['payment_method']
    end

    #葡幣賬戶號碼
    def mop_account_number(user)
      user.profile.data['personal_information']['field_values']['bank_of_china_account_mop']
    end


    #港幣賬戶號碼
    def hkd_account_number(user)
      user.profile.data['personal_information']['field_values']['bank_of_china_account_hkd']
    end

    def update_profile(user)
      unless user.location == location(user)
        profile = user.profile
        profile.send(
          :edit_field, {field: 'location', new_value: ProfileService.location_id(user), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
      unless user.department == department(user)
        profile = user.profile
        profile.send(
          :edit_field, {field: 'department', new_value: ProfileService.department_id(user), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
      unless user.position == position(user)
        profile = user.profile
        profile.send(
          :edit_field, {field: 'position', new_value: ProfileService.position_id(user), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end

      unless user.profile.data['position_information']['field_values']['date_of_employment']  == date_of_employment(user)&.strftime('%Y/%m/%d')
        profile = user.profile
        profile.send(
          :edit_field, {field: 'date_of_employment', new_value: date_of_employment(user)&.strftime('%Y/%m/%d'), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
      unless user.company_name == company_name(user)
        profile = user.profile
        profile.send(
          :edit_field, {field: 'company_name', new_value: company_name(user), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end

      unless user.grade == grade(user)
        profile = user.profile
        profile.send(
          :edit_field, {field: 'grade', new_value: grade(user), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
      unless user.employment_status == employment_status(user)
        profile = user.profile
        profile.send(
          :edit_field, {field: 'employment_status', new_value: employment_status(user), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
      unless user.division_of_job == division_of_job(user)
        profile = user.profile
        profile.send(
          :edit_field, {field: 'division_of_job', new_value: division_of_job(user), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
      unless user.group_id == group_id(user)
        profile = user.profile
        profile.send(
          :edit_field, {field: 'group', new_value: group_id(user), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end

      unless user.profile.data['position_information']['field_values']['date_of_employment'] == date_of_employment(user).strftime('%Y/%m%d')
        profile = user.profile
        profile.send(
          :edit_field, {field: 'date_of_employment', new_value: date_of_employment(user).strftime('%Y/%m/%d'), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
    end

    def update_resigned_date(user)
      unless user.profile.data['position_information']['field_values']['resigned_date'] == resigned_date(user)&.strftime('%Y/%m/%d')
        profile = user.profile
        profile.send(
          :edit_field, {field: 'resigned_date', new_value: resigned_date(user)&.strftime('%Y/%m/%d'), section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
      end
    end

    def location_for_all_user
      User.joins(:profile).all.each do |user|
        update_profile(user)
      end
    end

    #判断是否今年全勤
    def is_attend_the_whole_year(user, time)
      # 没有离职记录（当年）
      return false if  ResignationRecord.where(user_id: user.id).where("resigned_date > :resigned_date", resigned_date: time.beginning_of_year).count > 0
      # 7 是正式员工
      return false if !user.is_permanent_staff? rescue false
      # 9 入职满90天
      return false if user.career_entry_date && ((time.end_of_year - user.career_entry_date) / 1.day).round < 90
      # 1 没有请假记录（年假 生日假 有薪奖励病假 加班补假 有薪恩恤假除外 + 工伤（首7） +  工伤7天后）
      return false if (HolidayRecord.where(user_id: user.id, year: time.year).where.not(holiday_type: [0, 1, 2, 18, 9, 4, 5]).count > 0) rescue false
      # 1 没有旷工记录(遲到超過120次數 ＋ 曠工天數)
      return false if (AttendMonthlyReport.where(user_id: user.id, year: time.year).sum(:late_mins_more_than_120) > 0) rescue false
      return false if (AttendMonthlyReport.where(user_id: user.id, year: time.year).sum(:absenteeism_counts) > 0) rescue false
      # 4 没有迟到记录
      return false if (AttendMonthlyReport.where(user_id: user.id, year: time.year).sum(:late_counts) > 0) rescue false
      # 4 没有早退记录
      return false if (AttendMonthlyReport.where(user_id: user.id, year: time.year).sum(:leave_early_counts) > 0) rescue false
      # 沒有作为甲方借钟
      return false if (AttendMonthlyReport.where(user_id: user.id, year: time.year).sum(:as_a_in_borrow_hours_counts) > 0) rescue false

      true
    end

    #计算当年在职天数
    def work_days_in_this_year(user, year_month)
      _begin = [date_of_employment(user), year_month.beginning_of_year].max
      _end = [resigned_date(user)&.end_of_day, year_month.end_of_year.end_of_day].compact.min
      ((_end - _begin) / 1.day ).round(0)
    end



    #計算當月在職天數
    def work_days_in_this_month(user, year_month)
      begin_date = [year_month.beginning_of_month, user.career_records.order(career_begin: :asc).first&.career_begin].compact.max
      end_date = [year_month.end_of_month, ResignationRecord.where(user_id: user.id).order(created_at: :desc).first&.resigned_date&.end_of_day].compact.min
      if begin_date > year_month.end_of_month || end_date < year_month.beginning_of_month
        return 0
      else
        ((end_date - begin_date) / 1.day).round
      end
    end
    #計算在職天數
    def work_days(user)
      begin_date = user.career_records.order(career_begin: :asc).first.career_begin
      end_date = [user.resignation_records.where(status: :being_valid)&.first&.resigned_date, Time.zone.now.end_of_day].compact.min
      ((end_date - begin_date) / 1.day).round rescue 0
    end
    #計算在職年數(向下取整)
    def work_years(user)
      begin_date = user.career_records.order(career_begin: :asc).first.career_begin
      end_date = [user.resignation_records.where(status: :being_valid)&.first&.resigned_date, Time.zone.now.end_of_day].compact.min
      ((end_date - begin_date) / 1.year).floor rescue 0
    end

    #生成empoid
    def generate_empoid
      empoid =  self.generate_raw_empoid
      if is_valid_empoid?(self.generate_raw_empoid)
        empoid
      else
        self.generate_empoid
      end
    end

    def is_valid_empoid?(empoid)
     !User.pluck(:empoid).include? self.generate_raw_empoid
    end

    def generate_raw_empoid
      8.times.reduce("") do |result, index|
        result = result + Random.new().rand(0..9).to_s
      end
    end
  end
end
