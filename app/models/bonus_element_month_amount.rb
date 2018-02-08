# == Schema Information
#
# Table name: bonus_element_month_amounts
#
#  id                          :integer          not null, primary key
#  location_id                 :integer
#  float_salary_month_entry_id :integer
#  bonus_element_id            :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  department_id               :integer
#  level                       :string
#  subtype                     :string
#  amount                      :decimal(15, 4)
#
# Indexes
#
#  index_bonus_element_month_amounts_on_bonus_element_id       (bonus_element_id)
#  index_bonus_element_month_amounts_on_department_id          (department_id)
#  index_bonus_element_month_amounts_on_location_id            (location_id)
#  index_month_bonus_element_amounts_on_float_salary_entry_id  (float_salary_month_entry_id)
#
# Foreign Keys
#
#  fk_rails_0bc7be7bb8  (bonus_element_id => bonus_elements.id)
#  fk_rails_0d565a2e0d  (location_id => locations.id)
#  fk_rails_338595a79f  (float_salary_month_entry_id => float_salary_month_entries.id)
#

class BonusElementMonthAmount < ApplicationRecord
  belongs_to :location
  belongs_to :position
  belongs_to :float_salary_month_entry
  belongs_to :bonus_element

  enum level: { ordinary: 'ordinary', manager: 'manager' }
  enum subtype: { business_development: 'business_development', operation: 'operation' }

  scope :by_user_level, -> (user) {
    where(level: (user.grade < 3 ? :manager : :ordinary))
  }

  def self.query(params)
    query = BonusElementMonthAmount.all
    [
      :location_id,
      :department_id,
      :float_salary_month_entry_id,
      :bonus_element_id
    ].each do |attr|
      query = query.where(attr => params[attr]) unless params[attr].nil?
    end
    query
  end

  def self.batch_update(updates)
    BonusElementMonthAmount.update(
      updates.pluck(:id),
      updates.map { |up| ({ amount: up[:amount] }) }
    )
  end

  def self.header_to_bonus(language = nil)
    raw_header_to_bonus = [:cover_charge, :kill_bonus, :swiping_card_bonus, :collect_accounts_bonus, :exchange_rate_bonus, :vip_card_bonus, :zunhuadian, :xinchunlishi, :project_bonus, :shangpin_bonus]
    transfer_headers = raw_header_to_bonus.map{|item| I18n.t "bonus_element_month_amounts.xlsx_title_row.#{item}", locale: (language || I18n.locale)}
    [raw_header_to_bonus, transfer_headers].transpose.to_h
  end

  def self.level_header_to_bonus(language = nil)
    raw_header_to_bonus = [:percentage_of_rolling_bonus, :percentage_of_rolling_bonus_director]
    transfer_headers = raw_header_to_bonus.map{|item| I18n.t "bonus_element_month_amounts.xlsx_title_row.#{item}", locale: (language || I18n.locale)}
    [raw_header_to_bonus, transfer_headers].transpose.to_h
  end

  def self.subtype_header_to_bonus(language = nil)
    raw_header_to_bonus = [:each_market_planning_department_commission, :each_operating_commission]
    transfer_headers = raw_header_to_bonus.map{|item| I18n.t "bonus_element_month_amounts.xlsx_title_row.#{item}", locale: (language || I18n.locale)}
    [raw_header_to_bonus, transfer_headers].transpose.to_h
  end

  def self.ordinary_header(language = nil)
    raw_header_to_bonus = [:location, :department]
    transfer_headers = raw_header_to_bonus.map{|item| I18n.t "bonus_element_month_amounts.xlsx_title_row.#{item}", locale: (language || I18n.locale)}
    [raw_header_to_bonus, transfer_headers].transpose.to_h
  end


  def self.get_locale_hash
    hash = {}
    Dir[Rails.root.join('config', 'locales', 'models', 'float_salary_month_entries', 'bonus_element_month_amounts', '*.{rb,yml}')].each{|item| hash.merge!(YAML.load_file(item))}
    hash
  end

  def self.import_xlsx(file, float_salary_month_entry_id)
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    sheet = xlsx.sheet(xlsx.sheets.first)
    header = sheet.row(1)

    language = if get_locale_hash['zh-CN']['bonus_element_month_amounts']['xlsx_title_row'].values.include?(header.first)
                 :'zh-CN'
               elsif get_locale_hash['en']['bonus_element_month_amounts']['xlsx_title_row'].values.include?(header.first)
                 :en
               else
                 :'zh-HK'
               end
    I18n.locale == language

    header_to_bonus(language).values.each do |key|
      raise LogicError, "缺少表頭：#{key}" unless header.include?(key)
    end

    level_header_to_bonus(language).values.each do |key|
      raise LogicError, "缺少表頭：#{key}" unless header.include?(key)
    end

    subtype_header_to_bonus(language).values.each do |key|
      raise LogicError, "缺少表頭：#{key}" unless header.include?(key)
    end

    (2..sheet.last_row).each do |index|
      row = [header, sheet.row(index)].transpose.to_h
      #場館;部門
      location_chinese_name = row[row.keys[0]]
      department_chinese_name = row[row.keys[1]]

      location = Location.where(select_language => location_chinese_name).first
      raise LogicError, "沒有這個場館：#{location_chinese_name}" if location.nil?
      department = Department.where(select_language => department_chinese_name).first
      raise LogicError, "沒有這個部門：#{department_chinese_name}" if department.nil?

      header_to_bonus(language).each do |key, value|
        next if row[value].nil?
        amount_params = {
          location_id: location.id,
          department_id: department.id,
          float_salary_month_entry_id: float_salary_month_entry_id,
          bonus_element_id: BonusElement.find_by_key(key).id,
        }
        bonus_element_month_amount = BonusElementMonthAmount.where(amount_params).first_or_create(amount_params)
        if bonus_element_month_amount.amount
          bonus_element_month_amount
        else
          bonus_element_month_amount.update(amount: BigDecimal(row[value].to_s))
        end
      end
      #業績分紅百分比
      if row[row.keys[4]].present?
         amount_params = {
          location_id: location.id,
          department_id: department.id,
          float_salary_month_entry_id: float_salary_month_entry_id,
          bonus_element_id: BonusElement.find_by_key(:performance_bonus).id,
          level: 'ordinary'
        }
         bonus_element_month_amount = BonusElementMonthAmount.where(amount_params).first_or_create(amount_params)
         if bonus_element_month_amount.amount
           bonus_element_month_amount
         else
           bonus_element_month_amount.update(amount: BigDecimal(row[row.keys[4]].to_s))
         end
      end
      #業績分紅百分比（總監）
      if row[row.keys[5]].present?
         amount_params = {
          location_id: location.id,
          department_id: department.id,
          float_salary_month_entry_id: float_salary_month_entry_id,
          bonus_element_id: BonusElement.find_by_key(:performance_bonus).id,
          level: 'manager'
        }
         bonus_element_month_amount = BonusElementMonthAmount.where(amount_params).first_or_create(amount_params)
         if bonus_element_month_amount.amount
           bonus_element_month_amount
         else
           bonus_element_month_amount.update(amount: BigDecimal(row[row.keys[5]].to_s))
         end
      end
      #每份市場拓展部佣金差額
      if row[row.keys[7]].present?
        amount_params = {
          location_id: location.id,
          department_id: department.id,
          float_salary_month_entry_id: float_salary_month_entry_id,
          bonus_element_id: BonusElement.find_by_key(:commission_margin).id,
          subtype: 'business_development'
        }
        bonus_element_month_amount = BonusElementMonthAmount.where(amount_params).first_or_create(amount_params)
        if bonus_element_month_amount.amount
          bonus_element_month_amount
        else
          bonus_element_month_amount.update(amount: BigDecimal(row[row.keys[7]].to_s))
        end
      end
      #每份營運佣金差額
      if row[row.keys[8]].present?
        amount_params = {
          location_id: location.id,
          department_id: department.id,
          float_salary_month_entry_id: float_salary_month_entry_id,
          bonus_element_id: BonusElement.find_by_key(:commission_margin).id,
          subtype: 'operation'
        }
        bonus_element_month_amount = BonusElementMonthAmount.where(amount_params).first_or_create(amount_params)
        if bonus_element_month_amount.amount
          bonus_element_month_amount
        else
          bonus_element_month_amount.update(amount: BigDecimal(row[row.keys[8]].to_s))
        end
      end
    end
  end
end
