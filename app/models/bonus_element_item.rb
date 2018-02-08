# == Schema Information
#
# Table name: bonus_element_items
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  float_salary_month_entry_id :integer
#  location_id                 :integer
#  department_id               :integer
#  position_id                 :integer
#
# Indexes
#
#  index_bonus_element_items_on_department_id                (department_id)
#  index_bonus_element_items_on_float_salary_month_entry_id  (float_salary_month_entry_id)
#  index_bonus_element_items_on_location_id                  (location_id)
#  index_bonus_element_items_on_position_id                  (position_id)
#  index_bonus_element_items_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_39386a0575  (user_id => users.id)
#  fk_rails_60d9b8f80f  (location_id => locations.id)
#  fk_rails_a336556767  (department_id => departments.id)
#  fk_rails_c343a5f385  (position_id => positions.id)
#

class BonusElementItem < ApplicationRecord
  belongs_to :user
  has_many :bonus_element_item_values, dependent: :destroy
  belongs_to :position
  # belongs_to :department
  # belongs_to :location

  scope :by_float_salary_month_entry_id, -> (entry_id) {
    where(float_salary_month_entry_id: entry_id)
  }

  scope :by_employee_id, -> (employee_id) {
    where(users: { empoid: employee_id })
  }

  scope :by_employee_name, -> (employee_name) {
    where('users.chinese_name = :name OR users.english_name = :name OR users.simple_chinese_name = :name', name: employee_name)
  }

  scope :by_location_ids, -> (location_ids) {
    where(users: { location_id: location_ids })
  }

  scope :by_department_ids, -> (department_ids) {
    where(users: { department_id: department_ids })
  }

  scope :by_position_ids, -> (position_ids) {
    where(users: { position_id: position_ids })
  }

  class << self

    def query(params, sort_column, sort_direction)
      q = self.joins(:user)
      params.each do |key, value|
        q = q.send("by_#{key}", value)
      end
      case sort_column
      when :default
        q = q.order("users.empoid asc")
      when :employee_id
        q = q.order("users.empoid #{sort_direction}")
      when :employee_name
        q = q.order("users.chinese_name #{sort_direction}")
      when :location_ids
        q = q.order("users.location_id #{sort_direction}")
      when :department_ids
        q = q.order("users.department_id #{sort_direction}")
      when :position_ids
        q = q.order("users.position_id #{sort_direction}")
      else
        q = q.order(sort_column => sort_direction)
      end
      q
    end

    def options(params)
      q = self.joins(:user).by_float_salary_month_entry_id(params[:float_salary_month_entry_id])
      {
        departments: Department.where(id: q.select('users.department_id')).as_json,
        locations: Location.where(id: q.select('users.location_id')).as_json,
        positions: Position.where(id: q.select('users.position_id')).as_json,
      }
    end

    def generate_all(year_month_date)
      # User.salary_calculation_users.each do |user|
      ProfileService.float_salary_month_entries_users(year_month_date).find_each(batch_size: 50) do |user|
        generate(user, year_month_date)
      end
    end

    def generate(user, year_month_date)
      float_salary_month_entry = FloatSalaryMonthEntry
                                   .where(year_month: year_month_date.month_range)
                                   .first
      raise LogicError, 'not found float salary month entry' if float_salary_month_entry.nil?

      create_params = {
        user_id: user.id,
        float_salary_month_entry_id: float_salary_month_entry.id
      }
      item = where(create_params).first_or_create(create_params)

      BonusElement.all.each do |bonus_element|
        setting_query = bonus_element.bonus_element_settings
                          .where(department_id: user.department_id)
                          .where(location_id: user.location_id)

        next unless setting_query.exists?

        setting = setting_query.first.value
        case setting
        when 'departmental'
          # shares_query = BonusElementMonthShare
          #                  .where(float_salary_month_entry_id: float_salary_month_entry.id)
          #                  .where(location_id: user.location_id)
          #                  .where(department_id: user.department_id)
          #                  .where(bonus_element_id: bonus_element.id)
          # shares = shares_query.exists? ? shares_query.first.shares : nil

          bonus_key_to_attributes = {
            cover_charge: :final_tea_bonus,
            kill_bonus: :final_kill_bonus,
            performance_bonus: :final_performance_bonus,
            swiping_card_bonus: :final_charge_bonus,
            commission_margin: :final_commission_bonus,
            collect_accounts_bonus: :final_receive_bonus,
            exchange_rate_bonus: :final_exchange_rate_bonus,
            vip_card_bonus: :final_guest_card_bonus,
            zunhuadian: :final_respect_bonus,
            xinchunlishi: :final_new_year_bonus,
            project_bonus: :final_project_bonus,
            shangpin_bonus: :final_product_bonus,
          }.with_indifferent_access

          salary_records = SalaryRecord
                             .where(user_id: user.id)
                             .by_salary_begin_and_end(year_month_date.beginning_of_month, year_month_date.end_of_month)

          if salary_records.count == 1 &&
            salary_records.first.salary_begin <= year_month_date.beginning_of_month &&
            (salary_records.first.salary_end.nil? || salary_records.first.salary_end >= year_month_date.end_of_month)
            shares = ActiveModelSerializers::SerializableResource.new(salary_records.first).serializer_instance.send(bonus_key_to_attributes[bonus_element.key])
          else
            shares =
              salary_records.inject(BigDecimal(0)) do |sum, salary_record|
                value = ActiveModelSerializers::SerializableResource.new(salary_record).serializer_instance.send(bonus_key_to_attributes[bonus_element.key])
                begin_date = [float_salary_month_entry.year_month.beginning_of_month, salary_record.salary_begin].max
                end_date = [float_salary_month_entry.year_month.end_of_month, salary_record.salary_end&.end_of_day].compact.min
                sum + value / BigDecimal("30.0") * ((end_date - begin_date) / 1.day).round
              end
          end

          amount_query = BonusElementMonthAmount
                           .where(float_salary_month_entry_id: float_salary_month_entry.id)
                           .where(location_id: user.location_id)
                           .where(department_id: user.department_id)
                           .where(bonus_element_id: bonus_element.id)

          if bonus_element.subtypes.nil?
            # 经理级、普通员工特殊处理
            if amount_query.count > 1
              amount = amount_query.by_user_level(user).first&.amount
            else
              amount = amount_query.first&.amount
            end

            item
              .bonus_element_item_values
              .where(bonus_element: bonus_element)
              .first_or_create(bonus_element: bonus_element)
              .update(value_type: setting, shares: shares, per_share: amount)
          else
            bonus_element.subtypes.each do |subtype|
              subtype_query = amount_query.where(subtype: subtype)

              # 经理级、普通员工特殊处理
              if subtype_query.count > 1
                amount = subtype_query.by_user_level(user).first&.amount
              else
                amount = subtype_query.first&.amount
              end

              params = {
                bonus_element: bonus_element,
                subtype: subtype
              }
              item
                .bonus_element_item_values
                .where(params)
                .first_or_create(params)
                .update(value_type: setting, shares: shares, per_share: amount)
            end
          end
        when 'personal'
          item
            .bonus_element_item_values
            .where(bonus_element: bonus_element)
            .first_or_create(bonus_element: bonus_element)
            .update(value_type: setting)
        else
          raise LogicError, "unsupported bonus element setting #{setting}"
        end
      end  # BonusElement.all.each do |bonus_element|
      item.save!
    end  # def generate(user, year_month_date)
  end  # class << self


  def self.header_to_bonus(language = nil)
    raw_headers = ["tips_bonus", "win_lose_bonus", "rolling_bonus", "union_bonus", "receivable_bonus", "exchange_rate_bonus", "btm_bonus", "e_mall_bonus", "new_year_lai_see_bonus", "project_bonus", "luxe_bonus", "incentive_on_driving", "referral_bonus_on_rolling"]
    head_raw_headers_with_little_title = raw_headers[0..-3].map{|item| ["#{item}.shares", "#{item}.per", "#{item}.amount"]}.flatten
    tail_raw_headers_with_little_title = raw_headers[-2..-1]
    raw_headers_with_little_title = [head_raw_headers_with_little_title, tail_raw_headers_with_little_title].flatten
    transfer_headers = raw_headers_with_little_title.map do |item|
      part_1, part_2 = item.split('.')
      if part_2
        part_1 = I18n.t "bonus_element_items.xlsx_title_row_1.#{part_1}", locale: (language || I18n.locale)
        part_2 = I18n.t "bonus_element_items.xlsx_title_row_2.#{part_2}", locale: (language || I18n.locale)
        "#{part_1}.#{part_2}"
      else
        part_1 = I18n.t "bonus_element_items.xlsx_title_row_1.#{part_1}", locale: (language || I18n.locale)
        "#{part_1}"
      end
    end
    [raw_headers_with_little_title, transfer_headers].transpose.to_h
  end



  def self.subtype_header_to_bonus(language = nil)
    raw_headers = ["market_planning_department_commission", "operating_commission"]
    raw_headers_with_little_title = raw_headers.map{|item| ["#{item}.shares", "#{item}.per_share", "#{item}.amount"]}.flatten
    transfer_headers = raw_headers_with_little_title.map do |item|
      part_1, part_2 = item.split('.')
      part_1 = I18n.t "bonus_element_items.xlsx_title_row_1.#{part_1}", locale: (language || I18n.locale)
      part_2 = I18n.t "bonus_element_items.xlsx_title_row_2.#{part_2}", locale: (language || I18n.locale)
      "#{part_1}.#{part_2}"
    end
    [raw_headers_with_little_title, transfer_headers].transpose.to_h
  end

  def self.bonus_element_transfer(key)
    {
      tips_bonus: :cover_charge,
      win_lose_bonus: :kill_bonus,
      rolling_bonus: :performance_bonus,
      union_bonus: :swiping_card_bonus,
      receivable_bonus: :collect_accounts_bonus,
      exchange_rate_bonus: :exchange_rate_bonus,
      btm_bonus: :vip_card_bonus,
      e_mall_bonus: :zunhuadian,
      new_year_lai_see_bonus: :xinchunlishi,
      project_bonus: :project_bonus,
      luxe_bonus: :shangpin_bonus,
      market_planning_department_commission: :business_development,
      operating_commission: :operation,
      incentive_on_driving: :dispatch_bonus,
      referral_bonus_on_rolling: :recommend_new_guest_bonus
    }[key.to_sym]
  end

  def self.get_locale_hash
    hash = {}
    Dir[Rails.root.join('config', 'locales', 'models', 'float_salary_month_entries', 'bonus_element_items', '*.{rb,yml}')].each{|item| hash.merge!(YAML.load_file(item))}
    hash
  end

  def self.import_xlsx(file, float_salary_month_entry_id)
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    sheet = xlsx.sheet(xlsx.sheets.first)
    header = sheet.row(1)
    language = if get_locale_hash['zh-CN']['bonus_element_items']['xlsx_title_row_1'].values.include?(header.first)
                 :'zh-CN'
               elsif get_locale_hash['en']['bonus_element_items']['xlsx_title_row_1'].values.include?(header.first)
                 :en
               else
                 :'zh-HK'
               end
    I18n.locale == language

    header_to_bonus.values.each do |key|
      raise LogicError, "缺少表頭：#{key}" unless header.include?(key.split('.')[0])
    end

    subtype_header_to_bonus.values.each do |key|
      raise LogicError, "缺少表頭：#{key}" unless header.include?(key.split('.')[0])
    end
    header_2 = sheet.row(2)
    header_3 =header[5..-3].compact.map do |item|
              [item] * 3
    end.flatten
    header = [header[0..4], header_3, header[-2..-1]].flatten
    header = [header, header_2].transpose.map{|item|
      if item[1]
        "#{item[0]}.#{item[1]}"
      else
        item[0]
      end
    }
    (3..sheet.last_row).each do |index|
      row = [header, sheet.row(index)].transpose.to_h
      empoid = row[row.keys[0]]
      user_chinese_name = row[row.keys[1]]
      location_chinese_name = row[row.keys[2]]
      department_chinese_name = row[row.keys[3]]
      position_chinese_name = row[row.keys[4]]
      empoid = ( "000000000"+ empoid.to_s).match(/\d{8}$/)[0] if  /^[-+]?[0-9.]([0-9.]*)?$/ === empoid.to_s #if 语句兼容测试用
      user = User.where(empoid: empoid).first
      raise LogicError, "沒有這個員工：#{empoid}" if user.nil?
      user = User.where(select_language => user_chinese_name).first
      raise LogicError, "沒有這個員工：#{user_chinese_name}" if user.nil?
      location = Location.where(select_language => location_chinese_name).first
      raise LogicError, "沒有這個場館：#{location_chinese_name}" if location.nil?
      department = Department.where(select_language => department_chinese_name).first
      raise LogicError, "沒有這個部門：#{department_chinese_name}" if department.nil?
      position = Position.where(select_language => position_chinese_name).first
      raise LogicError, "沒有這個職位：#{position_chinese_name}" if position.nil?

      bonus_element_item = BonusElementItem.where(user_id: user.id, float_salary_month_entry_id: float_salary_month_entry_id).first
      raise LogicError, "沒有這個員工記錄：#{user.id}" if bonus_element_item.nil?
      header_to_bonus.each do |key, value|
        next if row[value].nil?
        item_params = {
          bonus_element_item_id: bonus_element_item.id,
          bonus_element_id: BonusElement.find_by_key(bonus_element_transfer(key.to_s.split('.')[0])).id
        }
        bonus_element_item_value = BonusElementItemValue.where(item_params).first_or_create(item_params)
        if [:dispatch_bonus, :recommend_new_guest_bonus].include? bonus_element_transfer(key.to_s.split('.')[0])
          if bonus_element_item_value.amount.nil?
            bonus_element_item_value.update(amount: BigDecimal(row[value].to_s))
          end
          next
        end

        if bonus_element_item_value.value_type == 'departmental'
          if bonus_element_item_value.per_share.nil? && key =~ /per/
            bonus_element_item_value.update(per_share: BigDecimal(row[value]))
          end
          if bonus_element_item_value.shares.nil? && key =~ /shares/
            bonus_element_item_value.update(shares: BigDecimal(row[value]))
          end
        else
          if bonus_element_item_value.amount.nil? && key =~ /amount/
            bonus_element_item_value.update(amount: BigDecimal(row[value].to_s))
          end
        end
      end


      subtype_header_to_bonus.each do |key, value|
        next if row[value].nil?
        item_params = {
          bonus_element_item_id: bonus_element_item.id,
          bonus_element_id: BonusElement.find_by_key('commission_margin').id,
          subtype: bonus_element_transfer(key.to_s.split('.')[0])
        }
        bonus_element_item_value = BonusElementItemValue.where(item_params).first_or_create(item_params)
        if bonus_element_item_value.value_type == 'departmental'
          if bonus_element_item_value.per_share.nil? && key =~ /per/
            bonus_element_item_value.update(per_share: BigDecimal(row[value]))
          end
          if bonus_element_item_value.shares.nil? && key =~ /shares/
            bonus_element_item_value.update(shares: BigDecimal(row[value]))
          end
        else
          if bonus_element_item_value.amount.nil? && key =~ /amount/
            bonus_element_item_value.update(amount: BigDecimal(row[value].to_s))
          end
        end
      end

    end
  end
end
