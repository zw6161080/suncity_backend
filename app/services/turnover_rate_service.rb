class TurnoverRateService
  class << self
    def calculate_turnover_rate(query_params)
      users = User.all.joins(:profile).includes(:profile, :career_records)
      date_begin = Time.zone.parse(query_params[:date_begin]).beginning_of_day
      date_end = Time.zone.parse(query_params[:date_end]).end_of_day
      career_records = CareerRecord.all
      resignation_records = ResignationRecord
                                .where('final_work_date >= :from AND final_work_date <= :to', from: date_begin, to: date_end)
                                .where(resigned_reason: query_params[:resigned_reason])

      # where('lent_begin >= :from AND lent_begin <= :to', from: date_begin, to: date_end)
      lent_records = LentRecord.all.joins(:career_record).includes(:career_record)
      museum_records =MuseumRecord.all.joins(:career_record).includes(:career_record)

      # museum_records =MuseumRecord.where('date_of_employment >= :from AND date_of_employment <= :to', from: date_begin, to: date_end)

      # 期末在职人数
      # 期末在职人数 - 期末在职并且没有调馆暂借的职称信息的user_id
      has_l_o_m_ids = (lent_records.pluck(:career_record_id) + museum_records.pluck(:career_record_id)).compact.uniq
      career_records_in_service = career_records
                           .where.not(id: has_l_o_m_ids)
                           .where('career_begin <= :date AND invalid_date >= :date', date: date_end)
      # 存在筛选进行筛选
      career_records_in_service = career_records_in_service.where(company_name: query_params[:company_name]) if query_params[:company_name]
      career_records_in_service = career_records_in_service.where(location_id: query_params[:location_id]) if query_params[:location_id]
      career_records_in_service = career_records_in_service.where(department_id: query_params[:department_id]) if query_params[:department_id]
      mc_career_records_user_ids = career_records_in_service.pluck(:user_id)

      # 符合条件的暂借
      lent_records_in_service =lent_records.where(career_record_id: career_records.where('career_begin <= :date AND invalid_date >= :date', date: date_end))
      lent_records_in_service = lent_records_in_service.where(:career_records => { company_name: query_params[:company_name] }) if query_params[:company_name]
      lent_records_in_service = lent_records_in_service.where(:career_records => { department_id: query_params[:department_id] }) if query_params[:department_id]
      lent_records_in_service = lent_records_in_service.where('temporary_stadium_id IN (:location) OR career_records.location_id IN (:location)', location: query_params[:location_id]) if query_params[:location_id]
      mc_lent_records_user_ids = lent_records_in_service.pluck(:user_id)
      # 符合条件的调馆
      museum_records_in_service = museum_records.where(career_record_id: career_records.where('career_begin <= :date AND invalid_date >= :date', date: date_end))
      museum_records_in_service = museum_records_in_service.where('museum_records.location_id IN (:location) OR career_records.location_id IN (:location)', location: query_params[:location_id]) if query_params[:location_id]
      museum_records_in_service = museum_records_in_service.where(:career_records => { company_name: query_params[:company_name] }) if query_params[:company_name]
      museum_records_in_service = museum_records_in_service.where(:career_records => { department_id: query_params[:department_id] }) if query_params[:department_id]
      mc_museum_records_user_ids = museum_records_in_service.pluck(:user_id)

      u_ids = (mc_career_records_user_ids + mc_lent_records_user_ids + mc_museum_records_user_ids).compact.uniq
      # 离职
      leave_records = resignation_records.includes(:user => :career_records)

      # 存在筛选条件时在职过的员工
      # 离职 - 职称符合
      career_records_leave = career_records.where('career_begin <= :to AND invalid_date >= :from', from: date_begin, to: date_end)
      career_records_leave = career_records_in_service.where(company_name: query_params[:company_name]) if query_params[:company_name]
      career_records_leave = career_records_leave.where(location_id: query_params[:location_id]) if query_params[:location_id]
      career_records_leave = career_records_leave.where(department_id: query_params[:department_id]) if query_params[:department_id]
      mc_leave_career_records_user_ids = career_records_leave.pluck(:user_id)
      # 离职 - 暂借符合
      lent_records_leave =lent_records.where(career_record_id: career_records.where('career_begin <= :to AND invalid_date >= :from', from: date_begin, to: date_end))
      lent_records_leave = lent_records_leave.where(:career_records => { company_name: query_params[:company_name] }) if query_params[:company_name]
      lent_records_leave = lent_records_leave.where(:career_records => { department_id: query_params[:department_id] }) if query_params[:department_id]
      lent_records_leave = lent_records_leave.where('temporary_stadium_id IN (:location) OR career_records.location_id IN (:location)', location: query_params[:location_id]) if query_params[:location_id]
      mc_leave_lent_records_user_ids = lent_records_leave.pluck(:user_id)
      # 离职 - 调馆符合
      museum_records_leave = museum_records.where(career_record_id: career_records.where('career_begin <= :to AND invalid_date >= :from', from: date_begin, to: date_end))
      museum_records_leave = museum_records_leave.where('museum_records.location_id IN (:location) OR career_records.location_id IN (:location)', location: query_params[:location_id]) if query_params[:location_id]
      museum_records_leave = museum_records_leave.where(:career_records => { company_name: query_params[:company_name] }) if query_params[:company_name]
      museum_records_leave = museum_records_leave.where(:career_records => { department_id: query_params[:department_id] }) if query_params[:department_id]
      mc_leave_museum_records_user_ids = museum_records_leave.pluck(:user_id)
      leave_ids = mc_leave_career_records_user_ids + mc_leave_lent_records_user_ids + mc_leave_museum_records_user_ids
      mc_leave_records = resignation_records.where(user_id: leave_ids).joins(:user => :profile)
      # 期末在职users
      in_service_at_end = users.where(id: u_ids).where.not(id: mc_leave_records.pluck(:user_id))
      # TODO 两条离职记录算2人次
      result = {}
      # 区分试用期内和试用期外
      in_service_career_records_1 = career_records_in_service.pluck(:id)
      in_service_career_records_2 = career_records.where(id: lent_records_in_service.pluck(:career_record_id))
      in_service_career_records_3 = career_records.where(id: museum_records_in_service.pluck(:career_record_id))
      in_service_career_records = career_records.where(id: (in_service_career_records_1 + in_service_career_records_2 + in_service_career_records_3).compact.uniq)

      # 期末在职
      in_service_in_probation_user_ids = in_service_career_records
                                             .where(employment_status: %w(trainee part_time informal_employees director_in_informal president_in_informal))
                                             .pluck(:user_id)
      in_service_out_probation_user_ids = in_service_career_records
                                              .where(employment_status: %w(formal_employees director president))
                                             .pluck(:user_id)
      # 试用期内在职
      in_service_in_probation_users = users.where(id: in_service_in_probation_user_ids).where.not(id: mc_leave_records.pluck(:user_id))
      # 试用期外在职
      in_service_out_probation_users = users.where(id: in_service_out_probation_user_ids).where.not(id: mc_leave_records.pluck(:user_id))
      # 试用期内离职
      leave_in_probation = mc_leave_records.where(employment_status: %w(trainee part_time informal_employees director_in_informal president_in_informal))
      # 试用期外离职
      leave_out_probation = mc_leave_records.where(employment_status: %w(formal_employees director president))
      result['all'] = { leave: mc_leave_records, in_service: in_service_at_end }
      result['in_probation'] = { leave: leave_in_probation, in_service: in_service_in_probation_users.where.not(id: mc_leave_records.pluck(:user_id)) }

      # 试用期外
      not_ids = []
      not_ids_leave = []
      # 試用期~1年：指離職記錄中離職類別為「正式員工」「總裁員工」「總監員工」的員工，但是入職不到1年；
      _begin = date_begin - 1.year
      _end = date_end - 1.year
      in_service = in_service_out_probation_users
                       .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: _begin)
                       .where("profiles.data #>> '{position_information, field_values, date_of_employment}' < :to", to: _end)
      leave = leave_out_probation
                         .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: _begin)
                         .where("profiles.data #>> '{position_information, field_values, date_of_employment}' < :to", to: _end)
      result['probation_to_one_year'] = { leave: leave.where.not(id: not_ids_leave), in_service: in_service }
      not_ids_leave = (not_ids_leave + leave.pluck(:id)).compact.uniq
      not_ids = (not_ids + in_service.pluck(:id)).compact.uniq
      # 1年~3年：指離職記錄中離職類別為「正式員工」「總裁員工」「總監員工」的員工，且入職滿不到1年但不到3年；
      _begin = date_begin - 3.year
      _end = date_end - 1.year
      in_service = in_service_out_probation_users
                       .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: _begin)
                       .where("profiles.data #>> '{position_information, field_values, date_of_employment}' < :to", to: _end)
      leave = leave_out_probation
                  .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: _begin)
                  .where("profiles.data #>> '{position_information, field_values, date_of_employment}' < :to", to: _end)
      result['one_to_three_year'] = { leave: leave.where.not(id: not_ids_leave), in_service: in_service.where.not(id: not_ids) }
      not_ids_leave = (not_ids_leave + leave.pluck(:id)).compact.uniq
      not_ids = (not_ids + in_service.pluck(:id)).compact.uniq
      # 3年~5年：指離職記錄中離職類別為「正式員工」「總裁員工」「總監員工」的員工，且入職滿不到3年但不到5年；
      _begin = date_begin - 5.year
      _end = date_end - 3.year
      in_service = in_service_out_probation_users
                       .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: _begin)
                       .where("profiles.data #>> '{position_information, field_values, date_of_employment}' < :to", to: _end)
      leave = leave_out_probation
                  .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: _begin)
                  .where("profiles.data #>> '{position_information, field_values, date_of_employment}' < :to", to: _end)
      result['three_to_five_year'] = { leave: leave.where.not(id: not_ids_leave), in_service: in_service.where.not(id: not_ids) }
      not_ids_leave = (not_ids_leave + leave.pluck(:id)).compact.uniq
      not_ids = (not_ids + in_service.pluck(:id)).compact.uniq
      # 5年以上：指離職記錄中離職類別為「正式員工」「總裁員工」「總監員工」的員工，且入職超過5年；
      _begin = date_begin - 5.year
      _end = date_end - 5.year
      in_service = in_service_out_probation_users
                       .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: _end)
      leave = leave_out_probation
                  .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: _end)
      result['more_than_five_year'] = { leave: leave.where.not(id: not_ids_leave), in_service: in_service.where.not(id: not_ids) }
      options = Config.get_all_option_from_selects(:turnover_rate_years)
      res = {}
      result.with_indifferent_access.each do |type, target_users|
        counts = {}
        leave = target_users['leave']
        in_service = target_users['in_service']
        under_num = leave.count + in_service.count
        under_num = 1 if under_num == 0
        rate = (BigDecimal(leave.count) / BigDecimal(under_num)).round(2) * 100 rescue 0
        counts['years'] = options.select { |op| op['key'] == type }.first
        counts['both'] = { leave: leave.count, in_service: in_service.count, rate: "#{rate}%" }
        leave_group_count = leave.group("profiles.data #>> '{position_information, field_values, local_or_foreign}'").count
        leave_local_count = (leave_group_count['local'] || 0) + (leave_group_count[nil] || 0)
        leave_foreign_count = (leave_group_count['profession'] || 0) + (leave_group_count['non-profession'] || 0)

        in_service_group_count = in_service.group("profiles.data #>> '{position_information, field_values, local_or_foreign}'").count
        in_service_local_count = (in_service_group_count['local'] || 0) + (in_service_group_count[nil] || 0)
        in_service_foreign_count = (in_service_group_count['profession'] || 0) + (in_service_group_count['non-profession'] || 0)
        under_num = leave_local_count + in_service_local_count
        under_num = 1 if under_num == 0
        local_rate = (BigDecimal(leave_local_count) / BigDecimal(under_num)).round(2) * 100 rescue 0
        under_num = leave_foreign_count + in_service_foreign_count
        under_num = 1 if under_num == 0
        foreign_rate = (BigDecimal(leave_foreign_count) / BigDecimal(under_num)).round(2) * 100 rescue 0
        counts['local'] = { leave: leave_local_count, in_service: in_service_local_count, rate: "#{local_rate}%" }
        counts['foreign'] = { leave: leave_foreign_count, in_service: in_service_foreign_count, rate: "#{foreign_rate}%" }
        res[type] = counts
      end
      res
    end
  end
end
