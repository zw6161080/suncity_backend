# coding: utf-8
# == Schema Information
#
# Table name: holiday_records
#
#  id                              :integer          not null, primary key
#  region                          :string
#  user_id                         :integer
#  is_compensate                   :boolean
#  start_date                      :date
#  start_time                      :datetime
#  end_date                        :date
#  end_time                        :datetime
#  days_count                      :integer
#  hours_count                     :integer
#  year                            :integer
#  is_deleted                      :boolean
#  comment                         :text
#  creator_id                      :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  source_id                       :integer
#  input_date                      :date
#  input_time                      :string
#  reserved_holiday_setting_id     :integer
#  holiday_type                    :string
#  change_to_general_holiday_count :integer
#
# Indexes
#
#  index_holiday_records_on_creator_id                   (creator_id)
#  index_holiday_records_on_reserved_holiday_setting_id  (reserved_holiday_setting_id)
#  index_holiday_records_on_user_id                      (user_id)
#

class HolidayRecord < ApplicationRecord
  belongs_to :user
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  belongs_to :reserved_holiday_setting

  has_many :holiday_record_histories, -> { order "updated_at DESC" }, class_name: 'HolidayRecord', foreign_key: 'source_id'

  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy

  has_many :taken_holiday_records, dependent: :destroy

  after_save :update_taken_holiday_record

  def update_taken_holiday_record
    TakenHolidayRecord.generate_taken_holiday_records
  end

  # enum holiday_type: { annual_leave: 0,
  #                      birthday_leave: 1,
  #                      paid_bonus_leave: 2,
  #                      compensatory_leave: 3,
  #                      paid_sick_leave: 4,
  #                      unpaid_sick_leave: 5,
  #                      unpaid_leave: 6,
  #                      paid_marriage_leave: 7,
  #                      unpaid_marriage_leave: 8,
  #                      paid_compassionate_leave: 9,
  #                      unpaid_compassionate_leave: 10,
  #                      maternity_leave: 11,
  #                      paid_maternity_leave: 12,
  #                      unpaid_maternity_leave: 13,
  #                      immediate_leave: 14,
  #                      absenteeism: 15,
  #                      work_injury: 16,
  #                      unpaid_but_maintain_position: 17,
  #                      overtime_leave: 18,
  #                      pregnant_sick_leave: 19,
  #                      reserved: 20
  #                    }

  scope :by_location_id, lambda { |location_id|
    if location_id
      joins(:user).where(users: { location_id: location_id })
    end
  }

  scope :by_department_id, lambda { |department_id|
    if department_id
      joins(:user).where(users: { department_id: department_id })
    end
  }

  scope :by_user, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  scope :by_holiday_date, lambda { |start_date, end_date|
    if start_date && end_date
      where("start_date >= ? AND start_date <= ?", start_date, end_date)
    elsif start_date && !end_date
      where("start_date >= ?", start_date)
    elsif !start_date && end_date
      where("start_date <= ?", end_date)
    end
  }

  scope :by_holiday_type, lambda { |type|
    where(holiday_type: type) if type
  }

  scope :by_is_deleted, lambda { |is_deleted|
    unless (is_deleted == 'true' || is_deleted == true)
      where(is_deleted: false).or(where(is_deleted: nil))
    end
  }

  scope :by_year, lambda { |year|
    where(year: year) if year
  }

  def self.find_holiday_type_in_date(user_id, date)
    holiday = HolidayRecord.where(user_id: user_id, source_id: nil)
                .where(is_deleted: [false, nil])
                .where("start_date <= ? AND end_date >= ?", date, date)
                .first
    holiday != nil ? holiday.holiday_type : nil
  end

  def self.find_holiday_count_in_date(type, date)
    HolidayRecord.where(holiday_type: type.fetch(:key), source_id: nil, is_deleted: [false, nil])
      .where("start_date <= ? AND end_date >= ?", date, date)
      .count
  end

  def self.calc_last_year_surplus(user, type, year)
    HolidayRecord.calc_surplus(user, type, year.to_i - 1)
  end

  # def self.calc_last_year_surplus(user, type, year)
  #   last_year = year.to_i - 1
  #   last_year_snapshot = SurplusSnapshot.where(user_id: user.id, holiday_type: type, year: last_year).first

  #   count = 0

  #   if last_year_snapshot == nil
  #     date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
  #     entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
  #     if entry != nil
  #       latest_y, current_y = entry.year, last_year
  #       if current_y >= latest_y
  #         tmp_count = HolidayRecord.calc_last_year_surplus(user, type, current_y) + HolidayRecord.calc_total(user, type, current_y) - HolidayRecord.calc_used(user, type, current_y)
  #         ss = SurplusSnapshot.find_or_create_by(user_id: user.id, holiday_type: type, year: current_y)
  #         ss.surplus_count = tmp_count > 0 ? tmp_count : 0
  #         ss.save!
  #         count = ss.surplus_count
  #       end
  #     end
  #   else
  #     count = last_year_snapshot.surplus_count
  #   end

  #   count
  # end

  def self.calc_total(user, type, year)
    case type
    when 'annual_leave'
      calc_annual_leave_count(user, year)
    when 'birthday_leave'
      calc_birthday_leave_count(user, year)
    when 'paid_bonus_leave'
      calc_release_paid_bonus_leave_count(user, year)
    when 'compensatory_leave'
      calc_compensatory_leave_count(user, year)
    when 'paid_sick_leave'
      calc_paid_sick_leave_count(user, year)
    when 'unpaid_sick_leave'
      calc_unpaid_sick_leave_count(user, year)
    when 'unpaid_leave'
      calc_unpaid_leave_count(user, year)
    when 'paid_marriage_leave'
      calc_paid_marriage_leave_count(user, year)
    when 'unpaid_marriage_leave'
      calc_unpaid_marriage_leave_count(user, year)
    when 'paid_compassionate_leave'
      calc_paid_compassionate_leave_count(user, year)
    when 'unpaid_compassionate_leave'
      calc_unpaid_compassionate_leave_count(user, year)
    when 'maternity_leave'
      calc_maternity_leave_count(user, year)
    when 'paid_maternity_leave'
      calc_paid_maternity_leave_count(user, year)
    when 'unpaid_maternity_leave'
      calc_unpaid_maternity_leave_count(user, year)
    when 'immediate_leave'
      calc_immediate_leave_count(user, year)
    when 'absenteeism'
      calc_absenteeism_count(user, year)
    when 'work_injury'
      calc_work_injury_count(user, year)
    when 'unpaid_but_maintain_position'
      calc_unpaid_but_maintain_position_count(user, year)
    when 'overtime_leave'
      calc_overtime_leave_count(user, year)

    when 'pregnant_sick_leave'
      calc_pregnant_sick_leave_count(user, year)
    else
      0
    end
  end

  def self.calc_used(user, type, year)
    t = Time.zone.local(year.to_i, 1, 1).to_date
    start_date = t.beginning_of_year
    end_date = t.end_of_year

    records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: type, start_date: start_date..end_date, is_deleted: [false, nil])
    counts = records.inject(0) do |sum, r|
      sum = type == 'overtime_leave' ? (sum + r.hours_count.to_i) : (sum + r.days_count.to_i)
    end
    counts
  end

  def self.calc_surplus(user, type, year)
    zero_group = ['unpaid_sick_leave', 'unpaid_leave', 'pregnant_sick_leave',
                  'immediate', 'absenteeism', 'work_injury', 'unpaid_but_maintain_position']

    total_minus_group = ['paid_marriage_leave', 'unpaid_marriage_leave', 'maternity_leave',
                         'paid_maternity_leave', 'unpaid_maternity_leave',
                         'birthday_leave',
                         'paid_sick_leave', 'paid_compassionate_leave', 'unpaid_compassionate_leave',
                        ]
    count = 0

    if zero_group.select { |t| t == type }.count > 0
      count = 0
    elsif total_minus_group.select { |t| t == type }.count > 0
      count = HolidayRecord.calc_total(user, type, year) - HolidayRecord.calc_used(user, type, year)

    elsif type == 'paid_bonus_leave'
      d = Time.zone.local(year, 1, 1).to_date.end_of_year
      count = HolidayRecord.calc_paid_bonus_leave_count_until_date(user, d)
    elsif type == 'compensatory_leave' || type == 'overtime_leave'
      total = HolidayRecord.calc_total(user, type, year)

      d = Time.zone.local(year, 1, 1).to_date.end_of_year
      records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: type, is_deleted: [false, nil])
                  .where("start_date < ?", d)

      used = records.inject(0) do |sum, r|
        sum = type == 'overtime_leave' ? (sum + r.hours_count.to_i) : (sum + r.days_count.to_i)
      end

      count = total - used
    elsif type == 'annual_leave'
      date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
      entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
      entry_year = entry.year
      total = [*entry_year.to_i .. year.to_i].reduce(0) do |sum, y|
        sum += HolidayRecord.calc_total(user, type, y)
        sum
      end

      d = Time.zone.local(year, 1, 1).to_date.end_of_year
      records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: type, is_deleted: [false, nil])
                  .where("start_date < ?", d)

      used = records.inject(0) do |sum, r|
        sum += r.days_count.to_i
        sum
      end

      count = total - used
      count > 0 ? count : 0
    else
      count = 0
    end

    count > 0 ? count : 0
  end

  # def self.calc_surplus(user, type, year)
  #   count = self.calc_last_year_surplus(user, type, year) + self.calc_total(user, type, year) - self.calc_used(user, type, year)
  #   if type == ''
  #   end
  #   snapshot = SurplusSnapshot.find_or_create_by(user_id: user.id, holiday_type: type, year: year)
  #   true_count = count > 0 ? count : 0
  #   snapshot.surplus_count = true_count
  #   snapshot.save!
  #   true_count
  # end

  def self.calc_annual_leave_count(user, year)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
    division_of_job = user.profile.data['position_information']['field_values']['division_of_job']
    employment_status = user.profile.data['position_information']['field_values']['employment_status']

    count = 0
    if entry != nil && entry.year <= year
      now = Time.zone.now.to_date
      date = Time.zone.local(year, 1, 1).to_date
      node = now.year == year ? now : date.end_of_year

      working_days = node >= entry ? (node - entry).to_i + 1 : 0

      if (division_of_job == 'front_office' && working_days >= 365)
        after_one_year = entry + 1.year
        if after_one_year.year == node.year
          count = (((12 - after_one_year.month) / 12.0) * 7).floor
        else
          final = (node.year - after_one_year.year - 1) + 7
          count = final > 12 ? 12 : final
        end

      # more = (working_days - 365) / 365
      # final = 7 + more
      # count = final > 12 ? 12 : final

      # wr = user.welfare_records.where(status: :being_valid).order(welfare_begin: :desc).first
      # wr_annual_leave_day = wr == nil ?
      #                         -1 :
      #                         ActiveModelSerializers::SerializableResource.new(
      #                           wr
      #                         ).serializer_instance.annual_leave.to_i

      # if wr_annual_leave_day > 0 && wr_annual_leave_day < 12
      #   more = working_days / 365

      #   final = wr_annual_leave_day + more
      #   count = final > 12 ? 12 : final
      # elsif wr_annual_leave_day == 12 || wr_annual_leave_day == 12.0
      #   count = 12
      # elsif wr_annual_leave_day == 15 || wr_annual_leave_day == 15.0
      #   count = 15
      # end
      elsif (division_of_job == 'back_office' && working_days > 0)
        # elsif (division_of_job == 'back_office' && working_days > 0 && (employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'))
        # wr = user&.welfare_records&.where(status: 'being_valid').order(welfare_begin: :desc).first
        # <<<<<<< HEAD
        wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
        t_wr = wr == nil || (wr&.id rescue -1) == -1 ?
                 nil :
                 ActiveModelSerializers::SerializableResource.new(
                   wr
                 ).serializer_instance

        probation = t_wr ? t_wr.probation.to_i : -1
        after_probation = probation != -1 ? entry + probation.day : nil

        annual_leave_day = t_wr ? t_wr.annual_leave.to_i : -1

        if (after_probation && node > after_probation)
          annual_l = annual_leave_day.to_i
          if node.year == after_probation.year
            count = ((((node.end_of_year - after_probation).to_i + 1) / 365.0) * annual_l).floor
          else
            count = annual_l
          end
        end
        # =======
        #         wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
        #         wr_annual_leave_day = wr == nil || (wr&.id rescue -1) == -1 ?
        #                                 -1 :
        #                                 ActiveModelSerializers::SerializableResource.new(
        #                                   wr
        #                                 ).serializer_instance.annual_leave.to_i

        #         count = wr_annual_leave_day.to_i
        # >>>>>>> upstream/develop
      end
    end
    # wr for welfare_record
    count
  end

  def self.calc_birthday_leave_count(user, year)
    # date_of_employment = user.profile.data.fetch('position_information').fetch('field_values').fetch('date_of_employment')
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    now = Time.zone.now.to_date
    date = Time.zone.local(year, 1, 1).to_date
    node = now.year == year ? now : date.end_of_year

    if entry && node
      service_year = (node - entry).to_i / 365
      service_year >= 1 ? 1 : 0
    else
      -1
    end
  end

  def self.calc_release_paid_bonus_leave_count(user, year)
    working_day = HolidayRecord.calc_working_day(user, year)

    if working_day > 0

      date = Time.zone.local(year, 1, 1).to_date

      now = Time.zone.now.to_date
      node = now.year == year ? now : date.end_of_year

      items = PaidSickLeaveReportItem.where("user_id = ? AND valid_period >= ?", user.id, node)
      count = 0
      count = items.reduce(0) { |sum, i| sum += i.obtain_counts.to_i }
      count
    else
      0
    end
  end

  def self.calc_paid_bonus_leave_count(user, year)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
    now = Time.zone.now.to_date

    node = now.year == year ? now : Time.zone.local(year, 1, 1).to_date

    year_begin = node.beginning_of_year
    year_end = node.end_of_year
    if entry && year_begin && year_end
      year_begin_working_day = entry > year_begin ? entry : year_begin
      year_working_days = year_begin_working_day > year_end ? 0 : ((year_end - year_begin_working_day).to_i + 1)

      year_apply = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'paid_sick_leave', is_deleted: [false, nil]).where(start_date: year_begin_working_day .. year_end)
      year_counts = year_apply.inject(0) { |sum, r| sum += r.days_count.to_i }

      paid_sick_leave_count = HolidayRecord.calc_paid_sick_leave_count(user, year)

      result = (((year_working_days / 365.0) * paid_sick_leave_count - year_counts) / 3).floor
      result > 0 ? result : 0
    else
      0
    end
  end

  def self.calc_compensatory_leave_count(user, year)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    now = Time.zone.now.to_date
    date = Time.zone.local(year, 1, 1).to_date
    node = now.year == year ? now : date.end_of_year

    if node && entry && node >= entry
      all_holidays = HolidaySetting.where(category: 'force_holiday',
                                          holiday_date: entry..node).pluck(:holiday_date)

      total = 0
      all_holidays.each do |d|
        ro = RosterObject.where(user_id: user.id, roster_date: d).first
        if ro && ro.class_setting_id != nil && ro.is_general_holiday != true
          total = total + 1
        end
      end

      # force_holiday_make_up = user.welfare_records.where(status: :being_valid).first.try(:force_holiday_make_up)

      wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
      force_holiday_make_up = wr == nil || (wr&.id rescue -1) == -1 ?
                                nil :
                                ActiveModelSerializers::SerializableResource.new(
                                  wr
                                ).serializer_instance.force_holiday_make_up

      if force_holiday_make_up == 'one_money_and_one_holiday'
        total = total * 1
      elsif force_holiday_make_up == 'two_money'
        total = 0
      elsif force_holiday_make_up == 'two_holiday'
        total = total * 2
      end

      # holiday_records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'compensatory_leave', is_deleted: [false, nil])
      #                     .where("start_date < ?", node.beginning_of_year)

      # holiday_days_count = holiday_records.inject(0) do |sum, r|
      #   sum += r.days_count.to_i
      # end

      # result = total - holiday_days_count
      # result > 0 ? result : 0
      total > 0 ? total : 0
    else
      0
    end
  end

  def self.calc_paid_sick_leave_count(user, year)
    employment_status = user.profile.data['position_information']['field_values']['employment_status']

    working_day = HolidayRecord.calc_working_day(user, year)

    count = 0
    if working_day > 0
      if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
        wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
        sick_leave = wr == nil || (wr&.id rescue -1) == -1 ?
                       nil :
                       ActiveModelSerializers::SerializableResource.new(
                         wr
                       ).serializer_instance.sick_leave
        count = sick_leave.to_i
      end
    end
    count
  end

  def self.calc_unpaid_sick_leave_count(user, year)
    0
  end

  def self.calc_unpaid_leave_count(user, year)
    0
  end

  def self.calc_paid_marriage_leave_count(user, year)
    working_day = HolidayRecord.calc_working_day(user, year)

    count = 0
    if working_day > 0
      employment_status = user.profile.data['position_information']['field_values']['employment_status']

      if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
        days = 3
        d = Time.zone.local(year, 1, 1).to_date
        used_days = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'paid_marriage_leave', is_deleted: [false, nil])
                      .where("start_date < ?", d).count
        result = days - used_days
        count = result > 0 ? result : 0
      end
    end
    count
  end

  def self.calc_unpaid_marriage_leave_count(user, year)
    working_day = HolidayRecord.calc_working_day(user, year)

    count = 0
    if working_day > 0
      employment_status = user.profile.data['position_information']['field_values']['employment_status']
      if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
        days = 2
        d = Time.zone.local(year, 1, 1).to_date
        used_days = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'unpaid_marriage_leave', is_deleted: [false, nil])
                      .where("start_date < ?", d).count
        result = days - used_days
        count = result > 0 ? result : 0
      end
    end
    count
  end

  def self.calc_paid_compassionate_leave_count(user, year)
    working_day = HolidayRecord.calc_working_day(user, year)

    count = 0
    if working_day > 0
      employment_status = user.profile.data['position_information']['field_values']['employment_status']
      if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
        count = 3
      end
    end
    count
  end

  def self.calc_unpaid_compassionate_leave_count(user, year)
    working_day = HolidayRecord.calc_working_day(user, year)

    count = 0
    if working_day > 0
      employment_status = user.profile.data['position_information']['field_values']['employment_status']
      if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
        count = 2
      end
    end
    count
  end

  def self.calc_maternity_leave_count(user, year)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    now = Time.zone.now.to_date
    date = Time.zone.local(year, 1, 1).to_date
    node = now.year == year ? now : date.end_of_year

    gender = user.profile.data['personal_information']['field_values']['gender']

    if entry && node && gender == 'female'
      service_year = (node - entry).to_i / 365
      days = service_year >= 1 ? 2 : 0
      used_days = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'maternity_leave', is_deleted: [false, nil]).count
      result = days - used_days
      result > 0 ? result : 0
    else
      0
    end
  end

  def self.calc_paid_maternity_leave_count(user, year)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
    now = Time.zone.now.to_date
    date = Time.zone.local(year, 1, 1).to_date
    node = now.year == year ? now : date.end_of_year

    # node = now.year == year ? now : (now - 1.year).end_of_year

    gender = user.profile.data['personal_information']['field_values']['gender']

    if entry && node && gender == 'female'
      service_year = (node - entry).to_i / 365
      days = service_year >= 1 ? 56 : 0
      d = Time.zone.local(year, 1, 1).to_date
      used_days = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'paid_maternity_leave', is_deleted: [false, nil])
                    .where("start_date < ?", d).count
      result = days - used_days
      result > 0 ? result : 0
    else
      0
    end
  end

  def self.calc_unpaid_maternity_leave_count(user, year)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
    now = Time.zone.now.to_date
    date = Time.zone.local(year, 1, 1).to_date
    node = now.year == year ? now : date.end_of_year
    # node = now.year == year ? now : (now - 1.year).end_of_year

    gender = user.profile.data['personal_information']['field_values']['gender']

    if entry && node && gender == 'female'
      service_year = (now - entry).to_i / 365
      days = service_year >= 1 ? 34 : 0
      d = Time.zone.local(year, 1, 1).to_date
      used_days = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'unpaid_maternity_leave', is_deleted: [false, nil])
                    .where("start_date < ?", d).count
      result = days - used_days
      result > 0 ? result : 0
    else
      0
    end
  end

  def self.calc_immediate_leave_count(user, year)
    0
  end

  def self.calc_absenteeism_count(user, year)
    0
  end

  def self.calc_work_injury_count(user, year)
    0
  end

  def self.calc_unpaid_but_maintain_position_count(user, year)
    0
  end

  def self.calc_overtime_leave_count(user, year)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    now = Time.zone.now.to_date
    date = Time.zone.local(year, 1, 1).to_date
    node = now.year == year ? now : date.end_of_year

    if node && entry && node >= entry
      overtime_records = OvertimeRecord.where(user_id: user.id, source_id: nil, compensate_type: 'holiday', overtime_start_date: entry..node, is_deleted: [false, nil])

      overtime_hours_count = overtime_records.inject(0) do |sum, r|
        sum += r.overtime_hours.to_i
      end

      overtime_mins_count = overtime_records.inject(0) do |sum, r|
        sum += r.vehicle_department_over_time_min.to_i
      end

      mins_to_hours_count = (overtime_mins_count / 30) % 2 == 0 ? overtime_mins_count / 60 : ((overtime_mins_count / 60) + 1)

      # holiday_records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'overtime_leave', start_date: entry..node, is_deleted: [false, nil])
      #                     .where("start_date < ?", node.beginning_of_year)

      # holiday_hours_count = holiday_records.inject(0) do |sum, r|
      #   sum += r.hours_count.to_i
      # end

      # result = overtime_hours_count + mins_to_hours_count - holiday_hours_count

      result = overtime_hours_count + mins_to_hours_count
      result > 0 ? result : 0
    else
      0
    end
  end

  def self.calc_pregnant_sick_leave_count(user, year)
    0
  end

  def self.fixed_holiday_type_table
    [
      {
        key: 'annual_leave',
        chinese_name: '年假',
        english_name: 'Annual Leave',
        simple_chinese_name: '年假',
      },

      {
        key: 'birthday_leave',
        chinese_name: '生日假',
        english_name: 'Birthday Leave',
        simple_chinese_name: '生日假',
      },

      {
        key: 'paid_bonus_leave',
        chinese_name: '有薪獎勵假',
        english_name: 'Paid Bonus Leave',
        simple_chinese_name: '有薪奖励假',
      },

      {
        key: 'compensatory_leave',
        chinese_name: '補假',
        english_name: 'Compensatory leave',
        simple_chinese_name: '补假',
      },

      {
        key: 'paid_sick_leave',
        chinese_name: '有薪病假',
        english_name: 'Paid Sick Leave',
        simple_chinese_name: '有薪病假',
      },

      {
        key: 'unpaid_sick_leave',
        chinese_name: '無薪病假',
        english_name: 'Unpaid Sick Leave',
        simple_chinese_name: '无薪病假',
      },

      {
        key: 'unpaid_leave',
        chinese_name: '無薪假',
        english_name: 'Unpaid Leave',
        simple_chinese_name: '无薪假',
      },

      {
        key: 'paid_marriage_leave',
        chinese_name: '有薪婚假',
        english_name: 'Paid Marriage Leave',
        simple_chinese_name: '有薪婚假',
      },

      {
        key: 'unpaid_marriage_leave',
        chinese_name: '無薪婚假',
        english_name: 'Unpaid Marriage Leave',
        simple_chinese_name: '无薪婚假',
      },

      {
        key: 'paid_compassionate_leave',
        chinese_name: '有薪恩恤假',
        english_name: 'Paid Compassionate Leave',
        simple_chinese_name: '有薪恩恤假',
      },

      {
        key: 'unpaid_compassionate_leave',
        chinese_name: '無薪恩恤假',
        english_name: 'Unpaid Compassionate Leave',
        simple_chinese_name: '无薪恩恤假',
      },

      {
        key: 'maternity_leave',
        chinese_name: '待產假',
        english_name: 'Maternity Leave',
        simple_chinese_name: '待产假',
      },

      {
        key: 'paid_maternity_leave',
        chinese_name: '有薪分娩假',
        english_name: 'Paid Maternity Leave',
        simple_chinese_name: '有薪分娩假',
      },

      {
        key: 'unpaid_maternity_leave',
        chinese_name: '無薪分娩假',
        english_name: 'Unpaid Maternity Leave',
        simple_chinese_name: '无薪分娩假',
      },

      {
        key: 'immediate_leave',
        chinese_name: '即告',
        english_name: 'Immediate Leave',
        simple_chinese_name: '即告',
      },

      {
        key: 'absenteeism',
        chinese_name: '曠工',
        english_name: 'Absenteeism',
        simple_chinese_name: '旷工',
      },

      {
        key: 'work_injury',
        chinese_name: '工傷',
        english_name: 'Work Injury',
        simple_chinese_name: '工伤',
      },

      {
        key: 'unpaid_but_maintain_position',
        chinese_name: '停薪留職',
        english_name: 'Unpaid But Maintain Position',
        simple_chinese_name: '停薪留职',
      },

      {
        key: 'overtime_leave',
        chinese_name: '加班補假',
        english_name: 'Overtime Leave',
        simple_chinese_name: '加班补假',
      },

      {
        key: 'pregnant_sick_leave',
        chinese_name: '懷孕病假',
        english_name: 'Pregnant Sick Leave',
        simple_chinese_name: '怀孕病假',
      },
    ]
  end

  def self.reserved_holiday_type_table
    reserved_holiday_settings = ReservedHolidaySetting.all.map do |setting|
      {
        key: "reserved_holiday_#{setting.id}",
        chinese_name: setting.chinese_name,
        english_name: setting.english_name,
        simple_chinese_name: setting.simple_chinese_name,
      }
    end
    reserved_holiday_settings
  end

  def self.holiday_type_table
    HolidayRecord.fixed_holiday_type_table + HolidayRecord.reserved_holiday_type_table
  end

  def self.deal_with_compensation(start_d, end_d, result)
    records = HolidayRecord.where(start_date: start_d .. end_d, is_compensate: true)

    records.each do |r|
      r.is_compensate = result
      AttendMonthlyReport.update_calc_status(r.user_id, r.start_date)
      AttendAnnualReport.update_calc_status(r.user_id, r.start_date)
      r.save!
    end
  end

  def self.calc_remaining(user, type, date)
    # year = date.year
    # last_year_remaining = self.calc_last_year_surplus(user, type, year)
    # used = self.calc_used_until_date(user, type, date)
    # count = last_year_remaining + total - used
    count = self.calc_total_until_date(user, type, date)
    count > 0 ? count : 0
  end

  def self.calc_used_until_date(user, type, date)
    start_date = date.beginning_of_year
    end_date = date

    records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: type, start_date: start_date..end_date, is_deleted: [false, nil])
    counts = records.inject(0) do |sum, r|
      sum += r.days_count.to_i
    end
    counts
  end

  def self.calc_total_until_date(user, type, date)
    case type
    when 'annual_leave'
      calc_annual_leave_count_until_date(user, date)
    when 'paid_bonus_leave'
      calc_paid_bonus_leave_count_until_date(user, date)
    when 'paid_sick_leave'
      calc_paid_sick_leave_count_until_date(user, date)
    else
      0
    end
  end

  def self.calc_annual_leave_count_until_date(user, date)
    d = date.in_time_zone.to_date
    annual_leave_count = HolidayRecord.calc_annual_leave_count(user, d.year)

    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    node = entry.year == d.year ? entry : d.beginning_of_year
    working_days = d >= node ? (d - node).to_i + 1 : 0

    total = ((working_days / 365.0) * annual_leave_count).floor

    records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'annual_leave', is_deleted: [false, nil]).where("start_date >= ? AND start_date <= ?", node, d)
    r_count = records.reduce(0) { |sum, r| sum += r.days_count.to_i }

    surplus_count = HolidayRecord.calc_last_year_surplus(user, 'annual_leave', d.year)

    count = total - r_count + surplus_count
    count > 0 ? count : 0
  end

  def self.calc_paid_bonus_leave_count_until_date(user, date)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    d = date.in_time_zone.to_date

    count = 0
    if d && d >= entry
      items = PaidSickLeaveReportItem.where("user_id = ? AND valid_period >= ?", user.id, d)
      o_count = items.reduce(0) { |sum, i| sum += i.obtain_counts.to_i }
      records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'paid_bonus_leave', is_deleted: [false, nil]).where("start_date <= ?", d)
      r_count = records.reduce(0) { |sum, r| sum += r.days_count.to_i }
      count = o_count - r_count
    end
    count > 0 ? count : 0
  end

  def self.calc_paid_sick_leave_count_until_date(user, date)
    employment_status = user.profile.data['position_information']['field_values']['employment_status']

    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    d = date.in_time_zone.to_date

    node = entry.year == d.year ? entry : d.beginning_of_year

    total = 0
    if d && d >= entry
      if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
        # wr = user.welfare_records.where(status: :being_valid).first
        wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
        sick_leave = wr == nil || (wr&.id rescue -1) == -1 ?
                       nil :
                       ActiveModelSerializers::SerializableResource.new(
                         wr
                       ).serializer_instance.sick_leave
        total = sick_leave.to_i
      end
    end

    records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: 'paid_sick_leave', is_deleted: [false, nil]).where("start_date >= ? AND start_date <= ?", node, d)
    r_count = records.reduce(0) { |sum, r| sum += r.days_count.to_i }

    count = total - r_count
    count > 0 ? count : 0
  end

  def self.calc_total_annual_leave_count_until_date(user, date)
    d = date.in_time_zone.to_date
    annual_leave_count = HolidayRecord.calc_annual_leave_count(user, d.year)

    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    node = entry.year == d.year ? entry : d.beginning_of_year
    working_days = d >= node ? (d - node).to_i + 1 : 0

    total = ((working_days / 365.0) * annual_leave_count).floor

    surplus_count = HolidayRecord.calc_last_year_surplus(user, 'annual_leave', d.year)

    count = total + surplus_count
    count > 0 ? count : 0
  end

  def self.calc_total_paid_bonus_leave_count_until_date(user, date)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    d = date.in_time_zone.to_date

    count = 0
    if d && d >= entry
      items = PaidSickLeaveReportItem.where("user_id = ? AND valid_period >= ?", user.id, d)
      o_count = items.reduce(0) { |sum, i| sum += i.obtain_counts.to_i }
      count = o_count
    end
    count > 0 ? count : 0
  end

  def self.calc_total_paid_sick_leave_count_until_date(user, date)
    employment_status = user.profile.data['position_information']['field_values']['employment_status']

    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    d = date.in_time_zone.to_date

    node = entry.year == d.year ? entry : d.beginning_of_year

    total = 0
    if d && d >= entry
      if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
        # wr = user.welfare_records.where(status: :being_valid).first
        wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
        sick_leave = wr == nil || (wr&.id rescue -1) == -1 ?
                         nil :
                         ActiveModelSerializers::SerializableResource.new(
                             wr
                         ).serializer_instance.sick_leave
        total = sick_leave.to_i
      end
    end

    count = total
    count > 0 ? count : 0
  end

  def self.calc_working_day(user, year)
    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
    now = Time.zone.now.to_date
    date = Time.zone.local(year, 1, 1).to_date
    node = now.year == year ? now : date.end_of_year

    count = 0
    if node >= entry
      count = (node - entry).to_i + 1
    end
    count
  end

  # validator
  def self.least_validator(user_id, type, start_date, end_date)
    ans = true
    if type == 'unpaid_but_maintain_position'
      ans = (end_date - start_date).to_i >= 30
    end
    ans
  end

  def self.only_one_validator(user_id, type, start_date, end_date, records)
    ans = true
    if type == 'paid_maternity_leave' || type == 'unpaid_maternity_leave'
      ans = records.where(user_id: user_id, holiday_type: type).count > 0 ? false : true
    end
    ans
  end

  def self.female_validator(user_id, type, start_date, end_date)
    ans = true
    if type == 'paid_maternity_leave' ||
       type == 'unpaid_maternity_leave' ||
       type == 'maternity_leave' ||
       type == 'pregnant_sick_leave'

      user = User.find_by(id: user_id)
      gender = user.profile.data['personal_information']['field_values']['gender'] if user
      ans = gender == 'female' ? true : false
    end
    ans
  end

  def self.birthday_date_validator(user_id, type, start_date, end_date)
    ans = true
    if type == 'birthday_leave'

      user = User.find_by(id: user_id)

      date_of_employment = user ? user.profile.data['position_information']['field_values']['date_of_employment'] : nil
      entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
      after_one_year = entry ? entry + 365.day : nil

      date_of_birth = user.profile.data['personal_information']['field_values']['date_of_birth'] if user
      b_day = (date_of_birth != nil && date_of_birth != "") ? date_of_birth.in_time_zone.to_date : nil

      if b_day && after_one_year
        # end_of_month = b_day.end_of_month
        birthday_range_start = after_one_year.year == start_date.year && after_one_year.month == b_day.month ?
                                 after_one_year + 1.day :
                                 Time.zone.local(start_date.year, b_day.month, 1).to_date
        birthday_range_end = birthday_range_start.end_of_month
        ans = (start_date >= birthday_range_start && end_date <= birthday_range_end) ? true : false
      else
        ans = false
      end
    end
    ans
  end

  def self.one_day_validator(user_id, type, start_date, end_date)
    ans = true
    if type == 'birthday_leave'
      ans = (start_date == end_date)
    end
    ans
  end

  def self.entry_validator(user_id, type, start_date, end_date)
    ans = true

    user = User.find_by(id: user_id)

    if user
      date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
      entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
      # now = Time.zone.now.to_date
      ans = entry != nil && start_date ? ((start_date - entry).to_i + 1) >= 1 : false
    else
      ans = false
    end

    ans
  end

  def self.one_year_of_entry_validator(user_id, type, start_date, end_date)
    ans = true

    if type == 'birthday_leave' ||
       type == 'paid_maternity_leave' ||
       type == 'unpaid_maternity_leave' ||
       type == 'maternity_leave'

      user = User.find_by(id: user_id)
      if user
        date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
        entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
        # now = Time.zone.now.to_date

        ans = entry != nil && start_date ? ((start_date - entry).to_i + 1) >= 365 : false
      end
    end

    ans
  end

  def self.pass_probation_validator(user_id, type, start_date, end_date)
    ans = true

    if type == 'paid_sick_leave' ||
       type == 'paid_marriage_leave' ||
       type == 'unpaid_marriage_leave' ||
       type == 'paid_compassionate_leave' ||
       type == 'unpaid_compassionate_leave'

      user = User.find_by(id: user_id)
      if user
        employment_status = user.profile.data['position_information']['field_values']['employment_status']
        if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
          ans = true
        else
          ans = false
        end
      else
        ans = false
      end
    end

    ans
  end

  def self.front_one_year_validator(user_id, type, start_date, end_date)
    ans = true

    user = User.find_by(id: user_id)
    division_of_job = user.profile.data['position_information']['field_values']['division_of_job']

    if type == 'annual_leave' && division_of_job == 'front_office'
      date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
      entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
      # now = Time.zone.now.to_date

      ans = entry != nil && start_date ? ((start_date - entry).to_i + 1) >= 365 : false
    end

    ans
  end

  def self.back_probation_validator(user_id, type, start_date, end_date)
    ans = true

    user = User.find_by(id: user_id)
    division_of_job = user.profile.data['position_information']['field_values']['division_of_job']

    if type == 'annual_leave' && division_of_job == 'back_office'
      # employment_status = user.profile.data['position_information']['field_values']['employment_status']
      date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
      entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

      if entry
        wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
        t_wr = wr == nil || (wr&.id rescue -1) == -1 ?
                 nil :
                 ActiveModelSerializers::SerializableResource.new(
                   wr
                 ).serializer_instance

        probation = t_wr ? t_wr.probation.to_i : -1
        after_probation = probation != -1 ? entry + probation.day : nil

        if after_probation && start_date && start_date >= after_probation
          # if employment_status == 'formal_employees' || employment_status == 'president' || employment_status == 'director'
          ans = true
        else
          ans = false
        end
      else
        ans = false
      end
    end

    ans
  end

  def self.surplus_validator(user_id, type, start_date, end_date, apply_days, apply_hours, record_id)
    ans = true
    user = User.find_by(id: user_id)
    year = start_date.year
    now = Time.zone.now.to_date
    surplus_count = 0

    r = record_id ? HolidayRecord.find_by(id: record_id) : nil
    should_add_days = r ? r.days_count.to_i : 0
    should_add_hours = r ? r.hours_count.to_i : 0

    # apply_count = (start_date - end_date).to_i + 1

    count = 0
    if type == 'annual_leave'
      # if year == now.year
      #   count = HolidayRecord.calc_total_until_date(user, type, now)
      # elsif year < now.year
      #   count = HolidayRecord.calc_surplus(user, type, year)
      # end

      count = HolidayRecord.calc_total_until_date(user, type, start_date) + should_add_days

      ans = count >= apply_days ? true : false
    # surplus_count = count - apply_days

    elsif type == 'paid_bonus_leave'

      count = HolidayRecord.calc_total_until_date(user, type, start_date) + should_add_days
      ans = count >= apply_days ? true : false
    # surplus_count = count - apply_days

    elsif type == 'birthday_leave' ||
          type == 'compensatory_leave' ||
          type == 'paid_sick_leave' ||
          type == 'paid_marriage_leave' ||
          type == 'unpaid_marriage_leave' ||
          type == 'paid_compassionate_leave' ||
          type == 'unpaid_compassionate_leave' ||
          type == 'paid_maternity_leave' ||
          type == 'unpaid_maternity_leave' ||
          type == 'maternity_leave'

      count = HolidayRecord.calc_surplus(user, type, year) + should_add_days
      ans = count >= apply_days ? true : false
    # surplus_count = count - apply_days

    elsif type == 'overtime_leave'
      count = HolidayRecord.calc_surplus(user, type, year) + should_add_hours
      ans = count >= apply_hours ? true : false
    # surplus_count = count - apply_hours
    elsif /reserved_holiday_\d+/.match(type)
      reserved_holiday_setting_id = type.split('_').last.to_i

      rhs = ReservedHolidaySetting.find_by(id: reserved_holiday_setting_id)
      total_count = rhs ? rhs.days_count.to_i : 0

      applied_rs = HolidayRecord.where(user_id: user_id, source_id: nil, is_deleted: [false, nil], holiday_type: type)

      applied_sum = applied_rs.reduce(0) do |s, re|
        s += re.days_count.to_i
        s
      end

      # rhp = ReservedHolidayParticipator.where(user_id: user_id, reserved_holiday_setting_id: reserved_holiday_setting_id).first

      tmp_sum = total_count - applied_sum

      count = (tmp_sum > 0) ? tmp_sum : 0
      ans = count >= apply_days ? true : false
    end

    [ans, count]
  end

  def self.no_roster_validator(user_id, type, start_date, end_date)
    ans = true
    if type == 'overtime_leave'

      user = User.find_by(id: user_id)
      user_ro = RosterObject.where(user_id: user&.id, roster_date: start_date).first
      roster_class = ClassSetting.find_by(id: user_ro&.class_setting_id)
      ans = roster_class ? true : false
    end
    ans
  end

  def self.roster_range_validator(user_id, type, start_date, end_date, start_time, end_time)
    ans = true
    if type == 'overtime_leave'
      apply_st_int = start_time.strftime("%H%M%S").to_i
      apply_end_int = end_time.strftime("%H%M%S").to_i + (end_date > start_date ? 1 : 0) * 1000000

      user = User.find_by(id: user_id)
      user_ro = RosterObject.where(user_id: user&.id, roster_date: start_date).first
      roster_class = user_ro ? ClassSetting.find_by(id: user_ro&.class_setting_id) : nil

      if roster_class
        st_to_int = roster_class.start_time.strftime("%H%M%S").to_i + (roster_class&.is_next_of_start == true ? 1 : 0) * 1000000
        end_to_int = roster_class.end_time.strftime("%H%M%S").to_i + (roster_class&.is_next_of_end == true ? 1 : 0) * 1000000
        ans = (apply_st_int >= st_to_int && apply_end_int <= end_to_int) ? true : false
      elsif user_ro && user_ro.working_time
        wk_time = user_ro.working_time

        tmp_start_time = wk_time.split('-').first
        tmp_start_hour = tmp_start_time.split(':').first.to_i
        true_start_hour = (tmp_start_hour % 24).to_s.rjust(2, '0')
        true_start_min = tmp_start_time.split(':').second.to_i.to_s.rjust(2, '0')
        is_start_next = tmp_start_hour / 24 == 1 ? true : false

        tmp_end_time = wk_time.split('-').last
        tmp_end_hour = tmp_end_time.split(':').first.to_i
        true_end_hour = (tmp_end_hour % 24).to_s.rjust(2, '0')
        true_end_min = tmp_end_time.split(':').second.to_i.to_s.rjust(2, '0')
        is_end_next = tmp_end_hour / 24 == 1 ? true : false

        st_to_int = "#{true_start_hour}#{true_start_min}00".to_i + (is_start_next == true ? 1 : 0) * 1000000
        end_to_int = "#{true_end_hour}#{true_end_min}00".to_i + (is_end_next == true ? 1 : 0) * 1000000
        ans = (apply_st_int >= st_to_int && apply_end_int <= end_to_int) ? true : false
      else
        ans = false
      end
    end
    ans
  end

  def self.reserved_holiday_validator(user_id, type, start_date, end_date)
    ans = true
    is_inside = true
    if /reserved_holiday_\d+/.match(type)
      reserved_holiday_setting_id = type.split('_').last.to_i

      rhp = ReservedHolidayParticipator.where(user_id: user_id, reserved_holiday_setting_id: reserved_holiday_setting_id).first
      ans = rhp ? true : false

      rhs = ReservedHolidaySetting.find_by(id: reserved_holiday_setting_id)
      date_begin = rhs.date_begin.in_time_zone.to_date
      date_end = rhs.date_end.in_time_zone.to_date

      is_inside = start_date >= date_begin && end_date <= date_end

      # total_count = rhs ? rhs.days_count.to_i : 0

      # applied_rs = HolidayRecord.where(user_id: user_id, source_id: nil, is_deleted: [false, nil], holiday_type: type)
      # applied_sum = applied_rs.reduce(0) do |s, r|
      #   s += r.days_count.to_i
      # end

      # tmp_sum = total_count - applied_sum

      # sum = ans && (tmp_sum > 0) ? tmp_sum : 0
    end
    [ans, is_inside]
  end

  def self.approval_type_table
    [
      {
        key: 'approved',
        chinese_name: '已審核',
        english_name: 'Approved',
        simple_chinese_name: '已审核',
      },

      {
        key: 'approving',
        chinese_name: '審核中',
        english_name: 'Approving',
        simple_chinese_name: '审核中',
      },

      {
        key: 'dismissed',
        chinese_name: '已駁回',
        english_name: 'Dismissed',
        simple_chinese_name: '已驳回',
      }
    ]
  end

  def self.format_export(result)
    result.map do |item|
      HolidayRecord.approval_type_table.map do |type|
        new_item = item.dup
        new_item[:approval_type] = type
        new_item
      end
    end.flatten
  end
end
