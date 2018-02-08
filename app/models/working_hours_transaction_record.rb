# == Schema Information
#
# Table name: working_hours_transaction_records
#
#  id            :integer          not null, primary key
#  region        :string
#  is_compensate :boolean
#  user_a_id     :integer
#  user_b_id     :integer
#  apply_type    :integer
#  apply_date    :date
#  start_time    :datetime
#  end_time      :datetime
#  hours_count   :integer
#  is_deleted    :boolean
#  comment       :text
#  creator_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  source_id     :integer
#  borrow_id     :integer
#  is_start_next :boolean          default(FALSE)
#  is_end_next   :boolean          default(FALSE)
#  can_be_return :boolean          default(TRUE)
#
# Indexes
#
#  index_working_hours_transaction_records_on_creator_id  (creator_id)
#  index_working_hours_transaction_records_on_user_a_id   (user_a_id)
#  index_working_hours_transaction_records_on_user_b_id   (user_b_id)
#

class WorkingHoursTransactionRecord < ApplicationRecord
  belongs_to :user_a, class_name: "User", foreign_key: "user_a_id"
  belongs_to :user_b, class_name: "User", foreign_key: "user_b_id"

  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  has_many :working_hours_transaction_record_histories, -> { order "updated_at DESC" }, class_name: 'WorkingHoursTransactionRecord', foreign_key: 'source_id'

  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy

  enum apply_type: { borrow_hours: 0, return_hours: 1 }

  scope :by_location_id, lambda { |location_id|
    if location_id
      user_ids = User.where(location_id: location_id)
      where(user_a_id: user_ids).or(where(user_b_id: user_ids))
    end
  }

  scope :by_department_id, lambda { |department_id|
    if department_id
      user_ids = User.where(department_id: department_id)
      where(user_a_id: user_ids).or(where(user_b_id: user_ids))
    end
  }

  scope :by_user, lambda { |user_ids|
    if user_ids
      where(user_a_id: user_ids).or(where(user_b_id: user_ids))
    end
  }

  scope :by_apply_date, lambda { |date|
    where(apply_date: date) if date
  }

  # scope :by_apply_date, lambda { |start_date, end_date|
  #   if start_date && end_date
  #     where("apply_date >= ? AND apply_date <= ?", start_date, end_date)
  #   elsif start_date && !end_date
  #     where("apply_date >= ?", start_date)
  #   elsif !start_date && end_date
  #     where("apply_date <= ?", end_date)
  #   end
  # }

  # scope :by_apply_date, lambda { |apply_date|
  #   where(apply_date: apply_date) if apply_date
  # }

  scope :by_apply_type, lambda { |type|
    where(apply_type: type) if type
  }

  scope :by_can_be_return, lambda { |can_be_return|
    where(can_be_return: can_be_return) if can_be_return
  }

  scope :by_is_deleted, lambda { |is_deleted|
    unless (is_deleted == 'true' || is_deleted == true)
      where(is_deleted: false).or(where(is_deleted: nil))
    end
  }


  def self.return_attend_state_type(r_id, user_id)
    r = WorkingHoursTransactionRecord.find(r_id)
    if r.apply_type == 'borrow_hours' && user_id == r.user_a_id
      'borrow_hours_as_a'
    elsif r.apply_type == 'return_hours' && user_id == r.user_a_id
      'return_hours_as_a'
    elsif r.apply_type == 'borrow_hours' && user_id == r.user_b_id
      'borrow_hours_as_b'
    elsif r.apply_type == 'return_hours' && user_id == r.user_b_id
      'return_hours_as_b'
    end
  end

  def self.deal_with_compensation(start_d, end_d, result)
    records = WorkingHoursTransactionRecord.where(apply_date: start_d .. end_d, is_compensate: true)

    records.each do |r|
      r.is_compensate = result
      AttendMonthlyReport.update_calc_status(r.user_a_id, r.apply_date)
      AttendAnnualReport.update_calc_status(r.user_a_id, r.apply_date)
      AttendMonthlyReport.update_calc_status(r.user_b_id, r.apply_date)
      AttendAnnualReport.update_calc_status(r.user_b_id, r.apply_date)
      r.save!
    end
  end

  def fmt_final_time
    date_of_start_time = self.is_start_next ? self.apply_date + 1.day : self.apply_date
    date_of_end_time = self.is_end_next ? self.apply_date + 1.day : self.apply_date

    start_time = self.start_time
    end_time = self.end_time

    t_start = Time.zone.local(
      date_of_start_time.year,
      date_of_start_time.month,
      date_of_start_time.day,
      start_time.hour,
      start_time.min,
      59
    ).to_datetime

    t_end = Time.zone.local(
      date_of_end_time.year,
      date_of_end_time.month,
      date_of_end_time.day,
      end_time.hour,
      end_time.min,
      59
    ).to_datetime

    [t_start, t_end]

  end

  def self.to_overtime_counts(user_id, a_date, from_date, to_date, is_compensate)
    till_date = to_date ? to_date : Time.zone.now.to_date
    whts = self.where(user_b_id: user_id,
                      source_id: nil,
                      is_deleted: [nil, false],
                      apply_type: 'borrow_hours')
    if a_date
      whts = whts.where(apply_date: a_date)
    end

    if from_date
      whts = whts.where("apply_date >= ?", from_date)
    end

    if to_date
      whts = whts.where("apply_date <= ?", to_date)
    end

    total = 0

    total = whts.reduce(0) do |sum, wht|
      ws = is_compensate == false ? WorkingHoursTransactionRecord.where(is_compensate: is_compensate) : WorkingHoursTransactionRecord.all
      return_wht = ws.where(borrow_id: wht.id, source_id: nil, is_deleted: [nil, false])&.first
      after_x_days = wht.user_a_id == nil ? wht.apply_date + 30.day : wht.apply_date + 10.day
      # should_add = (return_wht && return_wht.apply_date > after_x_days) || (wht.can_be_return == true && after_x_days < till_date)
      should_not_add = return_wht || (!return_wht && after_x_days > till_date)
      sum = should_not_add ? sum : (sum + wht&.hours_count)
      sum
    end

    total
  end

  def self.to_unpaid_leave_counts(user_id, a_date, from_date, to_date, is_compensate)
    till_date = to_date ? to_date : Time.zone.now.to_date
    whts = self.where(user_a_id: user_id,
                      source_id: nil,
                      is_deleted: [nil, false],
                      apply_type: 'borrow_hours')
    if a_date
      whts = whts.where(apply_date: a_date)
    end

    if from_date
      whts = whts.where("apply_date >= ?", from_date)
    end

    if to_date
      whts = whts.where("apply_date <= ?", to_date)
    end

    total = 0

    total = whts.reduce(0) do |sum, wht|
      ws = is_compensate == false ? WorkingHoursTransactionRecord.where(is_compensate: is_compensate) : WorkingHoursTransactionRecord.all
      return_wht = ws.where(borrow_id: wht.id, source_id: nil, is_deleted: [false, nil])&.first
      after_10_days = wht.apply_date + 10.day
      should_add = (return_wht && return_wht.apply_date >= after_10_days) || (!return_wht && after_10_days <= till_date)
      sum = should_add ? sum + 1 : sum
      sum
    end

    total
  end
end
