# coding: utf-8
# == Schema Information
#
# Table name: rosters
#
#  id                                    :integer          not null, primary key
#  department_id                         :integer
#  state                                 :string
#  region                                :string
#  shift_interval                        :jsonb
#  rest_day_amount_per_week              :jsonb
#  rest_day_interval                     :jsonb
#  in_between_rest_day_shift_type_amount :jsonb
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  snapshot_employees_count              :integer
#  location_id                           :integer
#  from                                  :date
#  to                                    :date
#  condition                             :jsonb
#
# Indexes
#
#  index_rosters_on_department_id  (department_id)
#  index_rosters_on_location_id    (location_id)
#  index_rosters_on_region         (region)
#

class Roster < ApplicationRecord
  belongs_to :location
  belongs_to :department
  has_many :shifts
  has_many :shift_groups
  has_many :items, class_name: 'RosterItem'
  has_many :shift_user_settings
  has_many :shift_employee_count_settings
  has_many :employees, through: :department
  has_one :setting, class_name: 'RosterSetting'

  before_create :fill_snapshot_employees_count
  before_save :validate_from_to_date
  after_create :generate_fixed_items
  validates :department_id, :presence => true
  validates :location_id, :presence => true

  include AASM

  # scope :by_month, lambda { |month|
  #   where(:month => month) if month
  # }

  # scope :by_year, lambda { |year|
  #   where(:year => year) if year
  # }

  scope :by_date, lambda { |from, to|
    # where("from = ? AND to = ?", from, to) if (from && to)

    where(from: from).where(to: to) if (from && to)
  }

  scope :by_location_id, lambda { |location_id|
    where(:location_id => location_id) if location_id
  }

  scope :by_department_id, lambda { |department_id|
    where(:department_id => department_id) if department_id
  }

  scope :by_location_id, lambda { |location_id|
    where(:location_id => location_id) if location_id
  }

  scope :by_region, lambda { |region|
    where(:region => region) if region
  }

  scope :inside_from_to, lambda { |from, to|
    # where("from >= ?", from).where("to <= ?", to) if (from && to)

    where(from: from .. to).where(to: from .. to) if (from && to)
  }

  scope :left_side_from_to, lambda { |from, to|
    # where("from < ?", from).where("to > ?", from).where("to <= ?", to) if (from && to)
    
    if (from && to)
      from_range = from.advance(years: -100) .. from.advance(days: -1)
      to_range = from.advance(days: 1) .. to
      where(from: from_range).where(to: to_range)
    end
  }

  scope :right_side_from_to, lambda { |from, to|
    # where("from >= ?", from).where("from < ?", to).where("to > ?", to) if (from && to)

    if (from && to)
      from_range = from .. to.advance(day: -1)
      to_range = to.advance(days: 1) .. to.advance(years: 100)
      where(from: from_range).where(to: to_range)
    end
  }

  scope :outside_from_to, lambda { |from, to|
    # where("from < ?", from).where("to > ?", to) if (from && to)

    if (from && to)
      from_range = from.advance(years: -100) .. from.advance(days: -1)
      to_range = to.advance(day: 1) .. to.advance(years: 100)
      where(from: from_range).where(to: to_range)
    end
  }


  aasm column: 'state' do
    state :unroster, initial: true
    state :rostering
    state :rostered

    event :start_roster do
      before do
        prepare_rosting
      end

      after do
        create_items
      end
      transitions from: :unroster, to: :rostering, if: :unroster?
      transitions from: :rostered, to: :rostering, if: :rostered?
    end

    event :end_roster do
      transitions from: :rostering, to: :rostered
    end
  end

  def department_employees_count
    # department.try(:employees_count).to_i
    User.where(location_id: self.location.id, department_id: self.department.id).count
  end

  def shift_user_setting_complete?
    self.shift_user_settings.count == self.snapshot_employees_count
  end

  def office_leave_count
    fixed_count = items.where(state: :fixed).pluck(:date).select { |d| d.saturday? || d.sunday? }.count
    normal_count = items.where.not(state: :fixed).where(leave_type: 'offical_leave').count
    fixed_count + normal_count
  end

  def roster_items_count
    fixed_count = items.where(state: :fixed).count
    shift_count = items.where.not(state: :fixed).where("shift_id > ?", 0).count
    office_leave_count = items.where.not(state: :fixed).where(leave_type: 'offical_leave').count
    fixed_count + shift_count + office_leave_count
  end

  def calc_holiday_count(type)
    user_ids = User.where(location_id: self.location.id, department_id: self.department.id).pluck(:id)
    holiday_ids = Holiday.where(user_id: user_ids).pluck(:id)
    holiday_items = HolidayItem.where(holiday_id: holiday_ids, holiday_type: type)
    from = self.from
    to = self.to
    holiday_items.map { |item| item.calc_count_inside_range(from, to) }.reduce(0, :+)
  end

  def annual_holiday_count
    calc_holiday_count(0) # annual_holiday
  end

  def birthday_holiday_count
    calc_holiday_count(1) # birthday_holiday
  end

  def other_leave_count
    calc_holiday_count(17) # other_leave
  end

  def rostered_state
    finished_count = roster_items_count
    total_count = (self.from .. self.to).to_a.count * department_employees_count
    finished_count == total_count
  end

  def prepare_rosting
    items.where(state: [:default, :holiday]).delete_all
  end

  def create_items
    conditions = schedule_conditions
    validate_schedule_conditions(conditions)

    solver = AutoSchedule::DLX.new(conditions)

    result = {}
    result = solver.outputSolution if solver.solve()

    # 放开约束条件
    if result.blank?
      conditions['confliction'] = []
      solver = AutoSchedule::DLX.new(conditions)
      result = solver.outputSolution if solver.solve()
    end

    if result.blank?
      conditions['partner'] = []
      solver = AutoSchedule::DLX.new(conditions)
      result = solver.outputSolution if solver.solve()
    end

    if result.blank?
      conditions['prefer-period'] = []
      solver = AutoSchedule::DLX.new(conditions)
      result = solver.outputSolution if solver.solve()
    end

    if result.blank?
      conditions['prefer-vacation'] = []
      solver = AutoSchedule::DLX.new(conditions)
      result = solver.outputSolution if solver.solve()
    end

    if result.blank? && conditions['staff-number'] != default_staff_number
      conditions['staff-number'] = default_staff_number
      solver = AutoSchedule::DLX.new(conditions)
      result = solver.outputSolution if solver.solve()
    end

    raise LogicError, { message: "There is no solution for this roster!" }.to_json if result.blank?

    result.each do |k, v|
      item = self.items.find_or_create_by({user_id: k.last, date: k.first})
      unless item.state == :fixed
        item.shift_id = v.to_i
        item.state = :holiday if item.shift_id.to_i == 0
        item.save
      end
      # self.items << RosterItem.new({user_id: k.last, date: k.first, shift_id: v.to_i})
    end

    self.condition = conditions
    self.save

    self.end_roster!
  end

  def schedule_conditions
    {
      'date-range' => schedule_range,
      'period' => self.shifts.map{|s| {'id' => s.id, 'name' => s.chinese_name, 'begin' => Roster.time_offset(s.start_time), 'end' => Roster.time_offset(s.end_time)}},
      'title' => [
        { 'id' => 1, 'name' => '普通员工' },
        { 'id' => 2, 'name' => '经理' },
        { 'id' => 3, 'name' => '主任' }
      ],
      'position' => self.department.positions.map do |p|
        {
          'id' => p.id,
          'name' => p.chinese_name,
          'min-rest-time' => self.setting.try(:shift_interval_hour).to_h.fetch(p.id, 10),
          'vacation' => self.setting.try(:rest_number).to_h.fetch(p.id, 2),
          'max-rest-gap' => self.setting.try(:rest_interval_day).to_h.fetch(p.id, 8),
          'max-period-type' => self.setting.try(:shift_type_number).to_h.fetch(p.id, 3)
        }
      end,
      'staff' => schedule_staffs,
      'staff-number' => schedule_staff_number,
      'prefer-period' => self.prefer_period_condition,
      'prefer-vacation' => self.prefer_vacation_condition,
      'partner' => self.shift_groups.where(is_together: true).map do |s|
        {
          'date-range' => [self.from, self.to],
          'staff-id' => s.member_user_ids
        }
      end,
      'confliction' => self.shift_groups.where(is_together: false).map do |s|
        {
          'date-range' => [self.from, self.to],
          'staff-id' => s.member_user_ids
        }
      end
    }
  end

  def validate_schedule_conditions(conditions)
    raise LogicError, { message: "员工的职位与与所有职位不一致" } unless conditions['staff'].map{|s| s['position-id']}.uniq.sort.to_set.subset?(conditions['position'].map{|p| p['id']}.uniq.sort.to_set)
    raise LogicError, { message: "员工的等级与与所有等级不一致" } unless conditions['staff'].map{|s| s['title-id']}.uniq.sort.to_set.subset?(conditions['title'].map{|p| p['id']}.uniq.sort.to_set)
  end

  # 限制 10个人  7天

  def schedule_staffs
    # staffs = self.department.employees.includes(:shift_state).select{|i| i.shift_state.nil? || i.shift_state.current_is_shift }.map do |e|
    staffs = self.department.employees.map do |e|
      {
        'id' => e.id,
        'name' => e.chinese_name,
        'title-id' => [3, 4].include?(e.grade) ? e.grade : 1,
        'position-id' => e.position_id
      }
    end
    raise 'User count should be less than 10;' if staffs.count > 10
    staffs
  end

  def schedule_range
    raise 'Date range should less than 7;' if self.availability.to_a.count > 7

    [self.from, self.to]
  end


  def schedule_staff_number
    staff_number_setting = self.shift_employee_count_settings.map do |set|
      {
        'date-range' => [set.date, set.date],
        'period-id' => [set.shift_id],
        'title-id' => set.grade_tag,
        'number-range' => [set.max_number, set.max_number]
      }
    end
    staff_number_setting.delete_if{|s| s['title-id'].to_s == 'total'}
    (default_staff_number + staff_number_setting).uniq
  end

  def default_staff_number
    self.schedule_staffs.group_by{|u| u['title-id']}.map{|t, v| [t, v.count]}.to_h.map do |t, c|
      {
        'date-range' => schedule_range,
        'period-id' => self.shifts.pluck(:id),
        'title-id' => t,
        'number-range' => [1, c]
      }
    end
  end

  def prefer_period_condition
    setting = []
    self.shift_user_settings.each do |set|
      setting << { 'staff-id' => set.user_id, 'date-range' => [self.from, self.to], 'period-id' => Array(set.shift_interval).map(&:to_i) }
      set.shift_special.each do |ss|
        setting << { 'staff-id' => set.user_id, 'date-range' => [ss['from'], ss['to']], 'period-id' => ss['shift_ids'].map(&:to_i) }
      end
    end
    setting
  end

  def prefer_vacation_condition
    setting = []
    self.shift_user_settings.each do |set|
      setting << { 'staff-id' => set.user_id, 'days' => self.availability.select{|tdate| set.rest_interval.include?(tdate.wday) } }
      set.rest_special.each do |rs|
        setting << { 'staff-id' => set.user_id, 'days' => ((rs['from'])..(rs['to'])).select{|tdate| rs['wdays'].include?(tdate.wday) } }
      end
    end
    setting
  end

  def fill_snapshot_employees_count
    self.snapshot_employees_count = User.where(location_id: self.location.id, department_id: self.department.id).count
  end

  def validate_from_to_date
    self.from && self.to &&
      self.from < self.to &&
      self.from.wday == 1 &&
      self.to.wday == 0
  end

  def empty_settings!
    self.class.setting_filed_keys.each do |field|
      self.update(field => nil)
    end

    self.empty_shifts!
    self.empty_shift_groups!

    self.save!
  end

  def empty_shifts!
    self.shifts.destroy_all
  end

  def empty_shift_groups!
    self.shift_groups.destroy_all
  end

  def dup_from_last_roster!
    unless last_roster
      return
    end

    the_last_roster = last_roster
    ActiveRecord::Base.transaction do
      self.empty_settings!

      self.class.setting_filed_keys.each do |field|
        self.update(field => the_last_roster.try(field))
      end

      the_last_roster.shifts.each do |shift|
        self.shifts << shift.dup
      end

      the_last_roster.shift_groups.each do |shift_group|
        self.shift_groups << shift_group.dup
      end
    end

  end

  def last_roster
    the_last_roster = Roster.by_department_id(self.department_id).by_location_id(self.location_id)
    the_last_roster = the_last_roster.where(self.class.arel_table[:id].lt(self.id)) if self.id
    the_last_roster.last
  end

  def availability
    (self.from)..(self.to)
  end

  def generate_fixed_items_for(user)
    unless user.shift_state.nil?
      # 无预设  或 预设生效时间在此排班表之后
      if user.shift_state.future_affective_date.blank? ||
         (user.shift_state.future_affective_date && user.shift_state.future_affective_date > self.to)
        unless user.shift_state.current_is_shift
          self.availability.to_a.each do |date|
            time_arr = ShiftState.parse_time_string(user.shift_state.current_working_hour)
            time_arr = RosterItem.caculate_time(date, time_arr.fetch(:start_time), time_arr.fetch(:end_time))
            data = {
              start_time: time_arr.fetch(:start_time),
              end_time: time_arr.fetch(:end_time),
              state: :fixed
            }
            find_or_create_one_item(date, user.id, data)
          end
        else
          # 對已存在的 item 由固定班 -> 輪班
          self.availability.to_a.each do |date|
            find_and_update_item_state(date, user.id, :default)
          end
        end

      # 预设生效时间在此排班表之前
      elsif (user.shift_state.future_affective_date && user.shift_state.future_affective_date < self.from)
        unless user.shift_state.future_is_shift

          self.availability.to_a.each do |date|
            time_arr = ShiftState.parse_time_string(user.shift_state.future_working_hour)
            time_arr = RosterItem.caculate_time(date, time_arr.fetch(:start_time), time_arr.fetch(:end_time))
            data = {
              start_time: time_arr.fetch(:start_time),
              end_time: time_arr.fetch(:end_time),
              state: :fixed
            }
            find_or_create_one_item(date, user.id, data)
          end
        else
          # 對已存在的 item 由固定班 -> 輪班
          self.availability.to_a.each do |date|
            find_and_update_item_state(date, user.id, :default)
          end
        end

      # 在排班表时间中生效
      elsif user.shift_state.future_affective_date
        self.availability.to_a.each do |date|
          if date < user.shift_state.future_affective_date
            unless user.shift_state.current_is_shift
              time_arr = ShiftState.parse_time_string(user.shift_state.current_working_hour)
              time_arr = RosterItem.caculate_time(date, time_arr.fetch(:start_time), time_arr.fetch(:end_time))
              data = {
                start_time: time_arr.fetch(:start_time),
                end_time: time_arr.fetch(:end_time),
                state: :fixed
              }
              find_or_create_one_item(date, user.id, data)
            else
              # 對已存在的 item 由固定班 -> 輪班
              find_and_update_item_state(date, user.id, :default)
            end
          elsif date >= user.shift_state.future_affective_date
            unless user.shift_state.future_is_shift
              time_arr = ShiftState.parse_time_string(user.shift_state.future_working_hour)
              time_arr = RosterItem.caculate_time(date, time_arr.fetch(:start_time), time_arr.fetch(:end_time))
              data = {
                start_time: time_arr.fetch(:start_time),
                end_time: time_arr.fetch(:end_time),
                state: :fixed
              }
              find_or_create_one_item(date, user.id, data)
            else
              # 對已存在的 item 由固定班 -> 輪班
              find_and_update_item_state(date, user.id, :default)
            end
          end
        end
      end
    end
  end

  def generate_fixed_items(new_user = nil)
    if new_user
      generate_fixed_items_for(new_user)
      self.availability.to_a.each do |date|
        item = self.items.find_or_create_by({ user_id: new_user.id, date: date })
        item.save
      end
    else
      self.department.employees.where(location_id: self.location.id).includes(:shift_state).each do |user|
        generate_fixed_items_for(user)
      end
      self.department.employees.where(location_id: self.location.id).each do |user|
        self.availability.to_a.each do |date|
          item = self.items.find_or_create_by({ user_id: user.id, date: date })
          item.save
        end
      end
    end

  end

  def find_or_create_one_item(date, user_id, data)
    item = self.items.find_or_create_by({user_id: user_id, date: date})
    item.shift_id = data[:shift_id].to_i
    item.start_time = data[:start_time] if data[:start_time]
    item.end_time = data[:end_time] if data[:end_time]
    item.state = data[:state]
    item.save
  end

  def find_and_update_item_state(date, user_id, state)
    if item = self.items.find_by(user_id: user_id, date: date)
      item.state = state
      item.save
    end
  end

  class << self
    def setting_filed_keys
      %w(shift_interval rest_day_amount_per_week rest_day_interval in_between_rest_day_shift_type_amount)
    end

    def is_setting_field?(field)
      field.in?(setting_filed_keys)
    end

    def time_offset(time_str)
      time_str.to_time.to_i - "00:00".to_time.to_i
    end
  end
end
