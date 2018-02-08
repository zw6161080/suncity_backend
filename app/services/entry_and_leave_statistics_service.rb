class EntryAndLeaveStatisticsService
  class << self

    def calculate_statistics(query_params)
      query_params = query_params.with_indifferent_access
      locations_with_departments = Location.all.includes(:departments)
      locations_with_departments = locations_with_departments.where(id: query_params[:location_id]) if query_params[:location_id]
      date_begin = Time.zone.parse(query_params[:date_begin]).beginning_of_day rescue nil
      date_end = Time.zone.parse(query_params[:date_end]).end_of_day rescue nil
      raise 'Date error' unless date_begin && date_end
      users = User.all
      career_records = CareerRecord.all
      lent_records = LentRecord.all
      museum_records = MuseumRecord.all
      resignation_records = ResignationRecord.all

      # 查询日期前一天
      target_date = date_begin - 1.day
      # 查询前离职
      leave_rs = resignation_records.where('final_work_date <= :date', date: target_date)
      # 原有人数
      # 基本职称符合
      in_service_count = {}
      # in_service_records = []
      in_service_careers = career_records
                               .where('career_begin <= :date AND career_records.invalid_date >= :date', date: target_date)
                               .where.not(user_id: leave_rs.pluck(:user_id))
                               .includes(:lent_records, :museum_records)
      in_service_careers.each do |career_record|
        lent_records = career_record.lent_records.where('lent_records.lent_begin <= :date', date: target_date)
        museum_records = career_record.museum_records.where('museum_records.date_of_employment <= :date', date: target_date)
        location_id = ProfileService.location_id(career_record.user, target_date)
        in_service_count[[career_record.company_name, location_id, career_record.department_id]] ||= 0
        in_service_count[[career_record.company_name, location_id, career_record.department_id]] += 1
        # h = {
        #     user_id: career_record.user_id,
        #     company_name: career_record.company_name,
        #     location_id: location_id,
        #     department_id: career_record.department_id
        # }
        # in_service_records << h
      end

      # 期间离职记录
      leave_counts = {}
      due_leave_records = resignation_records.where('final_work_date >= :from AND final_work_date <= :to', from: date_begin, to: date_end)
      due_leave_records.each do |leave_record|
        date = leave_record.final_work_date
        career = career_records.where(user_id: leave_record.user_id).where('career_begin <= :date AND invalid_date >= :date', date: date).first
        if career
          location_id = ProfileService.location_id(leave_record.user, date)
          leave_counts[[career.company_name, location_id, career.department_id]] ||= 0
          leave_counts[[career.company_name, location_id, career.department_id]] += 1
        end
      end
      # 查找统计范围
      # 职称信息符合范围的
      match_part_1 = career_records.where('career_begin <= :to AND invalid_date >= :from', from: date_begin, to: date_end)
      match_part_1 = match_part_1.where(company_name: query_params[:company_name]) if query_params[:company_name]
      match_part_1 = match_part_1.where(location_id: query_params[:location_id]) if query_params[:location_id]
      match_part_1 = match_part_1.where(department_id: query_params[:department_id]) if query_params[:department_id]
      # 调馆暂借后符合范围的
      match_part_2 = lent_records.where(career_record_id: match_part_1.ids)
      match_part_3 = museum_records.where(career_record_id: match_part_1.ids)
      if query_params[:location_id]
        match_part_2 = match_part_2.joins(:career_record).where(temporary_stadium_id: query_params[:location_id])
        match_part_3 = match_part_3.joins(:career_record).where(:museum_records => { location_id: query_params[:location_id] })
      end
      count_range_career_ids = match_part_1.pluck(:id) + match_part_2.pluck(:career_record_id) + match_part_3.pluck(:career_record_id)
      count_range_career_ids = count_range_career_ids.compact.uniq

      count_range_careers = career_records.where(id: count_range_career_ids)

      count_range_users = users.where(id: count_range_careers.pluck(:user_id))

      change_histories = []
      count_range_users.each do |user|
        careers = count_range_careers.where(user_id: user.id)
        careers.each do |career_record|
          lents = career_record.lent_records.where('lent_begin <= :to AND lent_begin >= :from', from: date_begin, to: date_end)
          museums = career_record.museum_records.where('date_of_employment <= :to AND date_of_employment >= :from', from: date_begin, to: date_end)
          history = {
              type: careers.minimum(:career_begin) == career_record.career_begin ? 'original' : 'transfer',
              user_id: user.id,
              date: career_record.career_begin,
              company_name: career_record.company_name,
              location_id: career_record.location_id,
              department_id: career_record.department_id
          }
          change_histories << history
          sorted_records = (lents + museums).sort_by do |r|
            if r.is_a? LentRecord
              r.lent_begin
            else
              r.date_of_employment
            end
          end
          sorted_records.each_with_index do |record, index|
            # 暂借开始的变动记录
            if record.is_a? LentRecord
              h = {
                  type: 'lent',
                  user_id: user.id,
                  date: record.lent_begin,
                  company_name: career_record.company_name,
                  location_id: record.temporary_stadium_id,
                  department_id: career_record.department_id
              }
              change_histories << h
              # 暂借结束的变动记录
              next_record = sorted_records[index + 1]
              date = career_record.invalid_date
              date = record.lent_end if record.lent_end
              if next_record
                date = next_record.lent_begin if next_record.is_a? LentRecord
                date = next_record.date_of_employment if next_record.is_a? MuseumRecord
              end
              location = career_record.location_id
              mr_before = museums.where('date_of_employment < :date', date: record.lent_begin).order(:date_of_employment => :desc).first
              location = mr_before.location_id if mr_before
              h = {
                  type: 'over_lent',
                  user_id: user.id,
                  date: date - 1.day,
                  company_name: career_record.company_name,
                  location_id: location,
                  department_id: career_record.department_id
              }
              change_histories << h
            else
              # 调馆的变动记录
              h = {
                  type: 'museum_in',
                  user_id: user.id,
                  date: record.date_of_employment,
                  company_name: career_record.company_name,
                  location_id: record.location_id,
                  department_id: career_record.department_id
              }
              change_histories << h
            end
          end
        end
      end
      counts = {}
      group_histories_by_user_id = change_histories.group_by { |h| h[:user_id] }
      group_histories_by_user_id.each { |user_id, histories|
        ordered_histories = histories.sort_by { |h| h[:date] }
        ordered_histories.each_with_index do |h, index|
          unless h[:type] == 'original'
            counts[[h[:company_name], h[:location_id], h[:department_id]]] ||= { in: 0, out: 0 }
            temp = counts[[h[:company_name], h[:location_id], h[:department_id]]]
            pre_h = ordered_histories[index - 1]
            counts[[pre_h[:company_name], pre_h[:location_id], pre_h[:department_id]]] ||= { in: 0, out: 0 }
            pre_temp = counts[[pre_h[:company_name], pre_h[:location_id], pre_h[:department_id]]]
            temp[:in] += 1
            pre_temp[:out] += 1
          end
        end
      }
      res = []
      locations_with_departments.each do |location|
        departments = location.departments.where.not(id: 1)
        departments = departments.where(id: query_params[:department_id]) if query_params[:department_id]
        departments.each do |department|
          company_names = %w(suncity_gaming_promotion_company_limited suncity_group_commercial_consulting suncity_group_tourism_limited tian_mao_yi_hang)
          company_names = query_params[:company_name] if query_params[:company_name]
          record = {}
          record['location'] = location
          record['department'] = department
          entry_records = career_records
                              .where(deployment_type: 'entry')
                              .where(location_id: location.id, department_id: department.id)
                              .where('career_begin >= :from AND career_begin <= :to', from: date_begin, to: date_end)
          %w(company_name location_id department_id).each do |column_name|
            entry_records = entry_records.where("#{column_name} in (?)", query_params[column_name]) if query_params[column_name]
          end
          original = 0
          entry = entry_records.count
          leave = 0
          lent_in = 0
          lent_out = 0
          company_names.each { |company_name|
            temp = counts[[company_name, location.id, department.id]] || { in: 0, out: 0 }
            in_service = in_service_count[[company_name, location.id, department.id]] || 0
            leave_tmp = leave_counts[[company_name, location.id, department.id]] || 0
            lent_in += temp[:in]
            lent_out += temp[:out]
            original += in_service
            leave += leave_tmp
          }
          record['date_begin'] = date_begin
          record['date_end'] = date_end
          record['original'] = original
          record['entry'] = entry
          record['leave'] = 0 - leave
          record['lent_in'] = lent_in
          record['lent_out'] = 0 - lent_out
          record['current'] = original + entry - leave + lent_in - lent_out
          res << record
        end
      end
      res
    end
  end
end
