module GenerateXlsxHelper
  def generate_attend_report(**args)
    result, table_fields, my_attachment, sheet_name = args[:result], args[:table_fields], args[:my_attachment], args[:sheet_name]
    name_key = select_language
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: sheet_name || 'Default') do |sheet|
      sheet.add_row table_fields.map{|field| field.fetch(name_key.to_sym) }, :b => true
      total = result.count
      index = 0
      result.each do |rst|
        row = table_fields.map{|field|
          field[:get_value].call(rst.with_indifferent_access, name_key: name_key)
        }
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_month_salary_report_table(year_month_users_ids, salary_values_ids, original_column_order, my_attachment)
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(:name => "default") do |sheet|

      language_hash = SalaryColumn.where(id: original_column_order).select('id', select_language).map do |value|
        [value['id'], value[select_language]]
      end.to_h

      sheet.add_row(
        original_column_order.map { |item|
          language_hash.with_indifferent_access[item.to_i]
        }
      )
      get_month_salary_report_row(year_month_users_ids, original_column_order, SalaryValue.where(id: salary_values_ids), sheet, my_attachment)
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def create_my_attachment(data_string, my_attachment)
    file_for_export = File.open("/tmp/#{SecureRandom.hex}", "wb+") do |f|
      f << data_string
    end
    attachment = Attachment.new
    attachment.seaweed_hash = Attachment.save_file_to_seaweed(file_for_export.path)
    attachment.file = file_for_export
    attachment.file_name = my_attachment.file_name
    attachment.save!
    my_attachment.update(status: :completed, attachment_id: attachment.id, download_process: 1)
    my_attachment
  end


  def generate_month_salary_report_by_left_table(year_month_users_ids, salary_values_ids, original_column_order, msa)
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(:name => "default") do |sheet|
      language_hash = SalaryColumn.where(id: original_column_order.insert(0, 0)).select('id', select_language).map do |value|
        [value['id'], value[select_language]]
      end.to_h

      sheet.add_row(
          original_column_order.map { |item|
            language_hash.with_indifferent_access[item.to_i]
          }
      )
      get_month_salary_report_row(year_month_users_ids, original_column_order, SalaryValue.where(id: salary_values_ids), sheet, msa)
    end
    file_for_export = File.open("/tmp/#{SecureRandom.hex}", "wb+") do |f|
      f << package.to_stream.read
    end
    attachment = Attachment.new
    attachment.seaweed_hash = Attachment.save_file_to_seaweed(file_for_export.path)
    attachment.file = file_for_export
    attachment.file_name = msa.file_name
    attachment.save!
    msa.update(status: :to_be_download, attachment_id: attachment.id)
    msa
  end


  def get_month_salary_report_row(year_month_users_ids, original_column_order, salary_values, sheet, my_attachment)
    total = year_month_users_ids.size
    index = 0
    year_month_users_ids.each do |year_month_user_id|
      year_month_user = SalaryValue.find(year_month_user_id)
      query = salary_values.where(user_id: year_month_user.user_id, salary_column_id: original_column_order)
      if year_month_user.resignation_record_id
        query = query.where(resignation_record_id: year_month_user.resignation_record_id)
      else
        query = query.where(salary_type: :on_duty, year_month: year_month_user.year_month)
      end

      salary_value_hash = query.map do |salary_value|
        [salary_value.salary_column_id, salary_value]
      end.to_h

      row =original_column_order.map do |item|
        salary_value = salary_value_hash.with_indifferent_access[item.to_i]
        get_final_salary_value(salary_value.nil? ? salary_value : ActiveModelSerializers::SerializableResource.new(salary_value, serializer: SalaryValueInExportSerializer).serializer_instance.value)
      end
      index += 1
      sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
    end
  end


  def sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
    my_attachment.update(download_process: BigDecimal(index) / BigDecimal(total)) if index % [1, total / 10].max == 0 || index == total
    sheet.add_row(row, :types => [:string] * row.count)
  end


  def get_final_salary_value(value)
    if value.is_a? Hash
      value.with_indifferent_access[select_language]
    elsif value.is_a? DateTime
      value.strftime('%Y/%m/%d')
    elsif [false, true].include?(value)
      if value
        {
          chinese_name: '是',
          english_name: 'true',
          simple_chinese_name: '是'
        }[select_language]
      else
        {
          chinese_name: '否',
          english_name: 'false',
          simple_chinese_name: '否'
        }[select_language]
      end
    else
      value
    end
  end

  def get_bonus_element_month_shares_titles
    title_array_1 = ["location", "department", "person_count", nil, "tie_shares", nil, "kill_bonus_shares", nil, "performance_bonus_shares", nil, "charge_bonus_shares", nil, "commission_bonus_shares", nil, "receive_bonus_shares", nil, "exchange_rate_bonus_shares", nil, "guest_card_bonus_shares", nil, "respect_bonus_shares", nil, 'new_year_bonus_shares', nil, "project_bonus_shares", nil, "product_bonus_shares", nil]
    title_array_1.map! do |item|
      if item.nil?
        item
      else
        I18n.t "bonus_element_month_shares.xlsx_title_row_1.#{item}"
      end
    end
    title_array_2 = [nil, nil, ["department_employees_count", 'all_department_employees_count'] * 13].flatten
    title_array_2.map! do |item|
      if item.nil?
        item
      else
        I18n.t "bonus_element_month_shares.xlsx_title_row_2.#{item}"
      end
    end
    {
      title_row_1: title_array_1,
      title_row_2: title_array_2
    }
  end

  def get_bonus_element_month_amounts_titles
    title_array_1 = ["location", "department", "cover_charge", "kill_bonus", "percentage_of_rolling_bonus", 'percentage_of_rolling_bonus_director', "swiping_card_bonus", 'each_market_planning_department_commission', "each_operating_commission", 'collect_accounts_bonus', "exchange_rate_bonus", 'vip_card_bonus', "zunhuadian", 'xinchunlishi', "project_bonus", 'shangpin_bonus']
    title_array_1.map! do |item|
      I18n.t "bonus_element_month_amounts.xlsx_title_row.#{item}"
    end
    {
      title_row: title_array_1,
    }
  end

  def get_bonus_element_month_items_titles
    title_array_1 = ["empoid", "name", "location", 'department', "position", 'tips_bonus', nil, nil, "win_lose_bonus", nil, nil, 'rolling_bonus', nil, nil, nil, "union_bonus", nil, nil, 'market_planning_department_commission', nil, nil, "operating_commission", nil, nil, 'receivable_bonus', nil, nil, "exchange_rate_bonus", nil, nil, 'btm_bonus', nil, nil, "e_mall_bonus", nil, nil, 'new_year_lai_see_bonus', nil, nil, "project_bonus", nil, nil, 'luxe_bonus', nil, nil, "incentive_on_driving", 'referral_bonus_on_rolling']
    title_array_1.map! do |item|
      if item.nil?
        item
      else
        I18n.t "bonus_element_items.xlsx_title_row_1.#{item}"
      end
    end
    # title_array_2 = [[nil] * 5, ['shares', "per", 'amount'] * 13, [nil] * 2].flatten
    title_array_2 = [[nil] * 5, ['shares', "per", 'amount'] * 2, ['shares', "per", 'basic_salary', 'amount'], ['shares', "per", 'amount'] * 10, [nil] * 2].flatten
    title_array_2.map! do |item|
      if item.nil?
        item
      else
        I18n.t "bonus_element_items.xlsx_title_row_2.#{item}"
      end
    end
    {
      title_row_1: title_array_1,
      title_row_2: title_array_2
    }
  end


  # 浮动薪金的KEY
  def _all_bonus_keys
    [
      :cover_charge, # 茶资
      :kill_bonus, # 杀数分红
      :performance_bonus, # 绩效奖金
      :swiping_card_bonus, # 刷卡奖金
      :commission_margin, # 佣金差额
      :collect_accounts_bonus, # 收账分红
      :exchange_rate_bonus, # 汇率分红
      :vip_card_bonus, # 贵宾卡消费
      :zunhuadian, # 尊华殿
      :xinchunlishi, # 新春利是
      :project_bonus, # 项目奖金
      :shangpin_bonus, # 尚品奖金
      :dispatch_bonus, # 出车奖金
      :recommend_new_guest_bonus # 推荐新客户转码奖金
    ]
  end


  def generate_bonus_element_month_shares_table(**args)
    shares, float_salary_month_entry, my_attachment = args[:shares], args[:float_salary_month_entry], args[:my_attachment]
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(:name => "default") do |sheet|
      title_arrays = get_bonus_element_month_shares_titles
      sheet.add_row(title_arrays[:title_row_1])
      sheet.add_row(title_arrays[:title_row_2])
      total = float_salary_month_entry.locations_with_departments&.inject(0) do |sum, location_with_department|
        sum += location_with_department['departments']&.count || 0
      end
      index = 0
      base_query = shares.joins(:bonus_element)
      float_salary_month_entry.locations_with_departments&.map do |location_with_department|
        query_with_location = base_query.where(location_id: location_with_department['id'])
        location_item_array = _all_bonus_keys[0..-3].map do |key|
          [key.to_sym,   query_with_location.where(bonus_elements: {key: key}).sum(:shares)]
        end.to_h
        location_with_department['departments'].map do |department|
          query_with_location_with_department = query_with_location.where(department_id: department['id'])
          items_array = _all_bonus_keys[0..-3].map do |key|
            [
              query_with_location_with_department.where(bonus_elements: {key: key}).first&.shares,
              location_item_array[key.to_sym]
            ]
          end.flatten
          row = [
                          location_with_department[select_language.to_s], department[select_language.to_s], department['employees_total'], location_with_department['employees_total'],
                          items_array
                        ].flatten
          index += 1
          sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
        end
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_bonus_element_month_amounts_table(**args)
    amounts, float_salary_month_entry, my_attachment = args[:amounts], args[:float_salary_month_entry], args[:my_attachment]
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(:name => "default") do |sheet|
      title_arrays = get_bonus_element_month_amounts_titles
      sheet.add_row(title_arrays[:title_row])
      total = float_salary_month_entry.locations_with_departments&.inject(0) do |sum, location_with_department|
        sum += location_with_department['departments']&.count || 0
      end
      index = 0
      base_query = amounts.joins(:bonus_element)
      float_salary_month_entry.locations_with_departments&.map do |location_with_department|
        query_with_location = base_query.where(location_id: location_with_department['id'])
        location_with_department['departments'].map do |department|
          query_with_location_and_department = query_with_location.where(department_id: department['id'])
          items_array = _all_bonus_keys[0..-3].map do |key|
            query_with_location_and_department_and_key  = query_with_location_and_department.where(bonus_elements: {key: key})
            if key == :performance_bonus
              [
                query_with_location_and_department_and_key.where(level: :ordinary).first&.amount,
                query_with_location_and_department_and_key.where(level: :manager).first&.amount
              ]
            elsif key == :commission_margin
              [
                query_with_location_and_department_and_key.where(subtype: :business_development).first&.amount,
                query_with_location_and_department_and_key.where(subtype: :operation).first&.amount
              ]
            else
              [
                query_with_location_and_department_and_key.first&.amount
              ]
            end
          end.flatten
          row = [
                          location_with_department[select_language.to_s], department[select_language.to_s],
                          items_array
                        ].flatten
          index += 1
          sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
        end
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end


  def generate_bonus_element_month_items_table(**args)
    items,  my_attachment, ids = args[:items], args[:my_attachment], args[:query_ids]
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(:name => "default") do |sheet|
      title_arrays = get_bonus_element_month_items_titles
      sheet.add_row(title_arrays[:title_row_1])
      sheet.add_row(title_arrays[:title_row_2])
      total = items&.count
      index = 0
      ids.each do |id|
        item = items.find(id)
        base_query = item.bonus_element_item_values.joins(:bonus_element)
        items_array_1 = _all_bonus_keys[0..-3].map do |key|
          query_with_key  = base_query.where(bonus_elements: {key: key})
          if key == :commission_margin
            [
                (format('%.2f', query_with_key.where(subtype: :business_development).first&.shares) rescue nil),
                (format('%.2f', query_with_key.where(subtype: :business_development).first&.per_share) rescue nil),
                (format('%.0f', query_with_key.where(subtype: :business_development).first&.amount) rescue nil),
                (format('%.2f', query_with_key.where(subtype: :operation).first&.shares) rescue nil),
                (format('%.2f', query_with_key.where(subtype: :operation).first&.per_share) rescue nil),
                (format('%.0f', query_with_key.where(subtype: :operation).first&.amount) rescue nil)
            ]

          elsif key == :performance_bonus
            [
                (format('%.2f', query_with_key.first&.shares) rescue nil),
                (format('%.4f', query_with_key.first&.per_share) rescue nil),
                (format('%.0f', query_with_key.first&.basic_salary) rescue nil),
                (format('%.0f', query_with_key.first&.amount) rescue nil)
            ]
          else
            [
                (format('%.2f', query_with_key.first&.shares) rescue nil),
                (format('%.2f', query_with_key.first&.per_share) rescue nil),
                (format('%.0f', query_with_key.first&.amount) rescue nil)
            ]
          end
        end
        items_array_2 = _all_bonus_keys[-2..-1].map do |key|
          [
            base_query.where(bonus_elements: {key: key}).first&.amount
          ]
        end
        row = [
          item.user.empoid, item.user&.send(select_language), item.user.location&.send(select_language), item.user.department&.send(select_language), item.user.position&.send("raw_#{select_language}"), items_array_1, items_array_2
        ].flatten
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_table(**args)
    input, my_attachment, table_name = args[:data], args[:my_attachment], args[:table_name]
    input = JSON.parse(args[:data]).with_indifferent_access if args[:data].is_a? String
    fields_lang = select_language
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(:name => table_name ||  "default") do |sheet|
      sheet.add_row input[:fields].values, :b => true
      total = input[:records].size
      index = 0
      input[:records].each do |record|
        row = input[:fields].keys.map { |k|
          res = record.fetch(k, '')
          if res.is_a?(ActiveRecord::Base)
            res.send(fields_lang)
          elsif res.is_a?(Hash)
            res.fetch(fields_lang.to_sym)
          else
            res
          end
        }
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_card_profiles_table(**args)
    columns, my_attachment, query = args[:columns], args[:my_attachment], args[:query]
    keys = %w(empo_chinese_name
            empo_english_name
            empoid
            entry_date
            sex
            nation
            status
            approved_job_name
            approved_job_number
            allocation_company
            allocation_valid_date
            approval_id
            new_approval_valid_date
            report_salary_unit
            labor_company
            date_to_submit_data
            new_or_renew
            certificate_type
            certificate_id
            certificate_valid_date
            date_to_submit_fingermold
            date_to_get_card
            card_id
            card_valid_date
            cancel_date

    )
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: 'CardProfiles') do |sheet|
      sheet.add_row(columns.values)
      total = query.size
      index = 0
      query.each do |record|
        row = []
        keys.each { |key|
          if record[key].nil?
            row.push ''
          else
            row.push record[key]
          end
        }
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_records_by_departments_table(**args)
    query, my_attachment = args[:query], args[:my_attachment]
    field_attributes = {
      department: '',
      train_times: '',
      total_train_times: '',
      total_train_costs: '',
      average_train_costs: '',
      average_attendance_rate: '',
      average_pass_rate: ''
    }
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: 'TrainingRecord(ByDepartment)') do |sheet|

      sheet.add_row(field_attributes.keys.map { |key| I18n.t "records_by_departments.xlsx_title.#{key}" })
      department_names = []
      query_id = []
      query.map do |record|
        unless department_names.include? record.department_chinese_name
          department_names.push record.department_chinese_name
          query_id.push record.id
        end
      end
      total = query_id&.size
      index = 0
      query_id.each do |id|
        row = []
        department_name = TrainRecord.find(id)["department_#{select_language.to_s}"]
        row.push department_name
        query = query.where("department_#{select_language.to_s}" => department_name)
        train_id = []
        total_cost = 0
        total_attendance_rate = 0
        total_pass_rate = 0
        query.each do |q|
          total_cost += q.train.train_cost unless q.train.train_cost.to_s == 'NaN'
          total_attendance_rate += q.attendance_rate unless q.attendance_rate.to_s == 'NaN'
          if q.train_result
            total_pass_rate += 1
          end
          unless train_id.include? q.train_id
            train_id.push q.train_id
          end
        end
        row.push train_id.length
        row.push query.count
        row.push total_cost.round
        if query.count == 0
          row.push 0
          row.push "0%"
          row.push "0%"
        else
          row.push (total_cost / query.count).round
          row.push "#{(total_attendance_rate * 100 / query.count).round }%"
          row.push "#{total_pass_rate * 100 / query.count }%"
        end
        row = r
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_all_records_table(**args)
    query, my_attachment = args[:query], args[:my_attachment]
    field_attributes = {
      empoid: '',
      name: '',
      department: '',
      position: '',
      train_name: '',
      train_number: '',
      date_of_train: '',
      train_type: '',
      train_cost: '',
      attendance_rate: '',
      train_result: ''
    }
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: 'AllRecords') do |sheet|
      sheet.add_row(field_attributes.keys.map { |key| I18n.t "all_records.xlsx_title.#{key}" })
      total = query.size
      index = 0
      query.find_each do |record|
        row = []
        row.push record.empoid
        row.push record[select_language]
        row.push record["department_#{select_language.to_s}"]
        row.push record["position_#{select_language.to_s}"]
        row.push record.train[select_language]
        row.push record.train.train_number.to_s
        row.push "#{record.train.train_date_begin.strftime('%Y/%m/%d')}~#{record.train.train_date_end.strftime('%Y/%m/%d')}"
        row.push record.train.train_template_type[select_language]
        row.push record.train.train_cost
        if record.attendance_rate.to_s == 'NaN'
          row.push ''
        else
          row.push "#{(record.attendance_rate * 100).to_i}%"
        end
        row.push I18n.t "all_records.train_result.#{record.train_result}"
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_all_trains_table(**args)
    query, my_attachment = args[:query], args[:my_attachment]
    fields_lang = select_language
    field_attributes = {
      empoid: 'empoid',
      name: '.',
      department: 'department',
      position: 'position',
      date_of_employment: 'profile.data.position_information.field_values.date_of_employment'
    }
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: 'AllTrains') do |sheet|
      sheet.add_row((field_attributes.keys.map { |key| I18n.t "all_trains.xlsx_title.#{key}" }).concat (Train.all.order(id: :asc).map { |key| "#{key[fields_lang]}(#{key.train_number})/#{key.train_template[fields_lang]}" }))
      total = query.size
      index = 0
      query.find_each do |record|
        row = field_attributes.map do |key, value|
          res = record.as_json(include: [:department, :position, :profile]).dig value
          if key.to_s =~ /date$/ && res.present? && res.respond_to?(:strftime)
            res = res.strftime('%Y/%m/%d')
          end
          [key, res]
        end.to_h
        user_information = field_attributes.keys.map { |k|
          res = row.fetch(k, '')
          if res.is_a? Hash
            res.with_indifferent_access[fields_lang]
          else
            res
          end
        }
        record_ids = record.trains.order(id: :asc).map { |key| key.id }
        trains_date = Train.all.order(id: :asc).map { |key|
          if record_ids.include?(key.id)
            "#{key.train_date_begin.strftime('%Y/%m/%d')}~#{key.train_date_end.strftime('%Y/%m/%d')}"
          else
            " "
          end
        }
        trains_information = user_information.concat trains_date
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, trains_information , index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_dismission_table(**args)
    query, my_attachment = args[:query], args[:my_attachment]
    fields_lang = select_language
    field_attributes = {
      apply_date: 'apply_date',
      dimission_type: 'dimission_type',
      employee_no: 'user.empoid',
      employee_name: 'user',
      company_name: 'company_name',
      location: 'user.location',
      department: 'user.department',
      group: 'group',
      position: 'user.position',
      inform_date: 'inform_date',
      last_work_date: 'last_work_date',
      final_work_date: 'final_work_date',
      creator: 'creator',
      created_at: 'created_at',
    }

    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: 'Dimissions') do |sheet|
      sheet.add_row(field_attributes.keys.map { |key| I18n.t "dismission.xlsx_title.#{key}" })
      total = query.size
      index = 0
      query.find_each do |record|
        row = field_attributes.map do |key, value|
          res = record.as_json(include: [
            {user: {include: [:department, :position, :location]}},
            {creator: {include: [:department, :position, :location]}}
          ]).dig value
          if key.to_s =~ /date$/ && res.present? && res.respond_to?(:strftime)
            res = res.strftime('%Y/%m/%d')
          end
          if key == :created_at
            res = res.strftime('%Y/%m/%d')
          end
          if key == :dimission_type
            res = I18n.t "dismission.type_enum.#{res}"
          end
          if key == :company_name
            res = Config.get_single_option(:company_name, res)
          end

          [key, res]
        end.to_h

        row = field_attributes.keys.map { |k|
          res = row.fetch(k, '')
          if res.is_a? ActiveRecord::Base
            res.send(fields_lang)
          elsif res.is_a? Hash
            res.with_indifferent_access.fetch(fields_lang.to_sym)
          else
            res
          end

        }
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def generate_goods_signing_table(**args)
    query, my_attachment, statement_columns = args[:query], args[:my_attachment], args[:statement_columns]
    name_attr = case I18n.locale
                when 'zh-CN'
                  'simple_chinese_name'
                when 'en'
                  'english_name'
                else
                  'chinese_name'
                end
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: 'default') do |sheet|
      sheet.add_row(statement_columns.map { |column| column[name_attr] })
      total = query.size
      index = 0
      query.map do |record|
        row = record.get_xlsx_data_row.values
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end

  def add_title(sheet,statement_columns, name_attr)
    sheet.add_row(statement_columns.map { |column| column[name_attr] })
  end

  def add_employee_fund_switching_report_title(sheet,statement_columns, name_attr)
    sheet.add_row(statement_columns[0..7].map { |column| column[name_attr] }.concat(statement_columns[8..-1].map { |column| [column[name_attr],nil, nil, nil, nil ] }).flatten)
    sheet.add_row(statement_columns[0..7].map { |column| '' }.concat(statement_columns[8..-1].map { |column| column['children'].map { |item| item[name_attr] } }).flatten)
  end

  def add_appraisal_report_title(sheet,statement_columns, name_attr)
    sheet.add_row(statement_columns[0..7].map { |column| column[name_attr] }.concat(statement_columns[8..-1].map { |column| [column[name_attr],nil, nil, nil, nil, nil, nil, nil, nil ] }).flatten)
    sheet.add_row(statement_columns[0..7].map { |column| '' }.concat(statement_columns[8..-1].map { |column| column['children'].map { |item| item[name_attr] } }).flatten)
  end


  def generate_statement_xlsx(**args)
    query, statement_columns, options, serializer, my_attachment, add_title = args[:query], args[:statement_columns], args[:options], args[:serializer], args[:my_attachment], args[:add_title]
    name_attr = case I18n.locale
                when 'zh-CN'
                  'simple_chinese_name'
                when 'en'
                  'english_name'
                else
                  'chinese_name'
                end
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: 'default') do |sheet|
      if add_title
        self.send(add_title,sheet,statement_columns, name_attr)
      else
        add_title(sheet,statement_columns, name_attr)
      end
      total = query.size
      index = 0
      query.each do |record|
        if serializer
          serializer = serializer.constantize if serializer.is_a? String
          data = ActiveModelSerializers::SerializableResource.new(record, include: '**', serializer: serializer, adapter: :attributes).as_json
        else
          data = ActiveModelSerializers::SerializableResource.new(record, include: '**', adapter: :attributes).as_json
        end
        data = data.with_indifferent_access # remove root
        data_row = statement_columns.map{|column| get_final_children_column(column)}.flatten.map do |column|
          get_column_value(data, column, name_attr, options)
        end
        row = data_row
        index += 1
        sheet_add_row_and_update_my_attachment_process(sheet, row, index, total, my_attachment)
      end
    end
    create_my_attachment(package.to_stream.read, my_attachment)
  end


  def get_final_children_column(column)
    if column['children']
      column['children'].map{|item| get_final_children_column(item)}
    else
      column
    end
  end


  def get_column_value(data, column, name_attr, options)
    res = data
    res = get_res_from_data(column.with_indifferent_access['data_index'] || column.with_indifferent_access['key'], res)
    unless column['value_type'] == 'date_range'
      if res.nil?
        return ''
      end
    end
    case column['value_type']
    when 'obj_value'
      res.fetch(name_attr)
    when 'date_value'
      if column['date_value_format']
        if res.is_a?(String)
          res
        else
          I18n.l(res, format: column['date_value_format'])
        end
      else
        if res.is_a?(String)
          res
        else
          res.strftime('%Y/%m/%d') unless res.is_a?(String)
        end
      end
    when 'number_value'
      res
    when 'date_range'
      res_begin = get_res_from_data(column['data_index_begin'], data)
      res_begin = I18n.l(res_begin, format: column['date_index_begin_format']) unless column['date_index_begin_format'].nil? || res_begin.nil?

      res_end = get_res_from_data(column['data_index_begin'], data)
      res_end = I18n.l(res_end, format: column['date_index_end_format']) unless column['date_index_end_format'].nil? || res_end.nil?
      "#{res_begin.to_s}#{column['join_format'].to_s}#{res_end.to_s}"
      when "array_value"
        if column['item_type'] == 'string_value'
          res.map { |item| get_res_from_data(column['item_index'], item)}.join(column['join_format'])
        elsif column['item_type'] == 'option_value'
          res.map { |item| options_res(options, column, get_res_from_data(column['item_index'], item), name_attr)}.join(column['join_format'])
        end
    else
      other_res(options, column, res, name_attr)

    end
  end


  def options_res(options, column, res, name_attr)
    option = options.as_json.dig(column['key'].to_s, 'options').find { |opt| opt['option_no'] == res.to_s || opt['option_no'] == res}
    option.fetch("description")
  end

  def other_res(options, column, res, name_attr)
    # when 'string_value', 'bool_value', 'select_value'
    if options.as_json.dig(column['key'].to_s, 'options').nil?
      return res
    end

    option = options.as_json.dig(column['key'].to_s, 'options').find { |opt| opt['key'] == res.to_s || opt['key'] == res || opt['id'] == res }
    if option.nil?
      return res
    end

    option.fetch(name_attr)
  end

  def get_res_from_data(index, data)
    index.split('.').each do |item|
      data = data.dig(data.is_a?(Array) ? item.to_i : item) unless data.nil?
    end
    data
  end



end
