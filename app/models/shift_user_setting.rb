# == Schema Information
#
# Table name: shift_user_settings
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  roster_id      :integer
#  shift_interval :jsonb
#  shift_special  :jsonb
#  rest_interval  :jsonb
#  rest_special   :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_shift_user_settings_on_roster_id  (roster_id)
#  index_shift_user_settings_on_user_id    (user_id)
#

class ShiftUserSetting < ApplicationRecord
  belongs_to :user
  belongs_to :roster
  validates :user_id, uniqueness: { scope: :roster_id, message: "should be setted once per roster." }

  before_save :validate_special_items
  before_save :validate_user

  # shift setting
  def add_shifts(shift_ids)
    self.shift_interval = (Array(self.shift_interval) + Array(shift_ids)).uniq
    self.shift_interval = self.shifts.pluck(:id) & self.shift_interval
    self.save
  end

  def remove_shifts(shift_ids)
    self.shift_interval = (Array(self.shift_interval) - Array(shift_ids)).uniq
    self.shift_interval = self.shifts.pluck(:id) & self.shift_interval
    self.save
  end

  def add_shift_special(shift_special_item)
    self.shift_special = Array(self.shift_special) << shift_special_item
    self.save
  end

  def remove_shift_special(shift_special_item_key)
    self.shift_special = Array(self.shift_special).delete_if{|item| item.fetch('key', nil)==shift_special_item_key}
    self.save
  end

  def update_shift_special_item(key, item_params)
    self.shift_special = Array(self.shift_special).map do |item|
      if item.fetch('key', nil) == key
        item['from'] = item_params[:from] if item_params[:from]
        item['to'] = item_params[:to] if item_params[:to]
        item['shift_ids'] = Array(item_params[:shift_ids]).uniq
      end
      item
    end
    self.save
  end

  # rest setting
  def add_rests(rest_wdays)
    self.rest_interval = (Array(self.rest_interval) + Array(rest_wdays)).uniq
    self.save
  end

  def remove_rests(rest_wdays)
    self.rest_interval = (Array(self.rest_interval) - Array(rest_wdays)).uniq
    self.save
  end

  def add_rest_special(rest_special_item)
    self.rest_special = Array(self.rest_special) << rest_special_item
    self.save
  end

  def remove_rest_special(rest_special_item_key)
    self.rest_special = Array(self.rest_special).delete_if{|item| item.fetch('key', nil)==rest_special_item_key}
    self.save
  end

  def update_rest_special_item(key, item_params)
    self.rest_special = Array(self.rest_special).map do |item|
      if item.fetch('key', nil) == key
        item['from'] = item_params[:from] if item_params[:from]
        item['to'] = item_params[:to] if item_params[:to]
        item['wdays'] = Array(item_params[:wdays]).uniq
      end
      item
    end
    self.save
  end

  def shifts
    self.roster.shifts
  end

  def empty_settings!
    self.shift_interval = []
    self.shift_special = []
    self.rest_interval = []
    self.rest_special = []
    self.save
  end

  def dup_from_previous
    self.empty_settings!

    self.shift_interval = self.shift_interval_from_previous_roster
    self.rest_interval = Array(self.previous_roster_setting.try(:rest_interval))
    self.save
  end

  def shift_interval_from_previous_roster
    new_shift_interval = []
    shift_map = self.last_roster_shift_ids_map
    Array(previous_roster_setting.try(:shift_interval)).each do |shift_id|
      new_shift_interval.push(shift_map[shift_id]) if shift_map[shift_id]
    end
    new_shift_interval
  end

  def last_roster_shift_ids_map
    last_roster = self.roster.last_roster
    return [] unless last_roster
    previous_roster_shifts = last_roster.shifts.map{|s| [[s.chinese_name, s.english_name], s.id]}.to_h
    the_shifts = shifts.map{|s| [[s.chinese_name, s.english_name], s.id]}.to_h
    shifts_map = {}
    previous_roster_shifts.each do |ce_name, id|
      shifts_map[id] = the_shifts[ce_name] if the_shifts[ce_name]
    end
    shifts_map
  end

  def previous_roster_setting
    last_roster = self.roster.last_roster
    return nil unless last_roster
    last_roster.shift_user_settings.find_by_user_id(self.user_id)
  end

  def validate_special_items
    validate_shift_special_items && validate_rest_special_items
  end

  def validate_shift_special_items
    if Array(self.shift_special).all?{|item| ShiftSpecialItem.new(item, self).validate }
      self.shift_special = Array(self.shift_special).map{|item| ShiftSpecialItem.new(item, self).item_value }
    else
      false
    end
  end

  def validate_rest_special_items
    if Array(self.rest_special).all?{|item| RestSpecialItem.new(item).validate }
      self.rest_special  = Array(self.rest_special).map{|item| RestSpecialItem.new(item).item_value }
    else
      false
    end
  end

  def validate_user
    unless self.user.department_id == self.roster.department_id
      raise LogicError, { message: "Wrong User!" }.to_json
    end
  end

  class ShiftSpecialItem
    def initialize(shift_special, shift_user_setting)
      @shift_user_setting = shift_user_setting
      @key = shift_special['key']
      @from = shift_special['from']
      @to = shift_special['to']
      @shift_ids = (Array(shift_special['shift_ids']) & @shift_user_setting.shifts.pluck(:id)).uniq
    end

    def validate
      begin
         Date.parse(@from) <= Date.parse(@to)
      rescue
         raise LogicError, { message: "Wrong date!" }.to_json
      end
    end

    def item_value
      {
        key: generate_key,
        from: @from,
        to: @to,
        shift_ids: @shift_ids
      }
    end

    def generate_key
      @key = SecureRandom.uuid unless @key
      @key
    end

  end

  class RestSpecialItem
    def initialize(rest_special)
      @key = rest_special['key']
      @from = rest_special['from']
      @to = rest_special['to']
      @wdays = Array(rest_special['wdays'])
    end

    def validate
      date_validate && wday_validate
    end

    def date_validate
      begin
        Date.parse(@from) <= Date.parse(@to)
      rescue
        raise LogicError, { message: "Wrong date!" }.to_json
      end
    end

    def wday_validate
      all_wdays = (Date.parse(@from)..Date.parse(@to)).map{|k| k.wday }.uniq
      wday_validate = (@wdays - all_wdays).blank?
      raise LogicError, { message: "There is no #{Date::DAYNAMES[(@wdays - all_wdays).first]} during this period!" }.to_json unless wday_validate
      wday_validate
    end

    def item_value
      {
        key: generate_key,
        from: @from,
        to: @to,
        wdays: @wdays
      }
    end

    def generate_key
      @key = SecureRandom.uuid unless @key
      @key
    end

  end

end
