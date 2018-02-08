# == Schema Information
#
# Table name: adjust_roster_records
#
#  id                           :integer          not null, primary key
#  region                       :string
#  user_a_id                    :integer
#  user_b_id                    :integer
#  user_a_adjust_date           :date
#  user_a_roster_id             :integer
#  user_b_adjust_date           :date
#  user_b_roster_id             :integer
#  apply_type                   :integer
#  is_director_special_approval :boolean
#  is_deleted                   :boolean
#  comment                      :text
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  creator_id                   :integer
#  special_approver             :string
#
# Indexes
#
#  index_adjust_roster_records_on_creator_id        (creator_id)
#  index_adjust_roster_records_on_user_a_id         (user_a_id)
#  index_adjust_roster_records_on_user_a_roster_id  (user_a_roster_id)
#  index_adjust_roster_records_on_user_b_id         (user_b_id)
#  index_adjust_roster_records_on_user_b_roster_id  (user_b_roster_id)
#

class AdjustRosterRecord < ApplicationRecord
  belongs_to :user_a, class_name: "User", foreign_key: "user_a_id"
  belongs_to :user_b, class_name: "User", foreign_key: "user_b_id"

  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  belongs_to :roster_a, class_name: "RosterObject", foreign_key: "user_a_roster_id"
  belongs_to :roster_b, class_name: "RosterObject", foreign_key: "user_b_roster_id"

  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy

  enum apply_type: { for_class: 0, for_holiday: 1 }


  scope :by_location_id, lambda { |location_id|
    if location_id
      user_ids = User.where(location_id: location_id)
      where(user_a_id: user_ids).or(where(user_b_id: user_ids))
      # joins(:user).where(users: { location_id: location_id })
    end
  }

  scope :by_department_id, lambda { |department_id|
    if department_id
      user_ids = User.where(department_id: department_id)
      where(user_a_id: user_ids).or(where(user_b_id: user_ids))
      # joins(:user).where(users: { department_id: department_id })
    end
  }

  scope :by_user, lambda { |user_ids|
    if user_ids
      where(user_a_id: user_ids).or(where(user_b_id: user_ids))
    end
  }

  scope :by_adjust_date, lambda { |date|
    if date
      where(user_a_adjust_date: date).or(where(user_b_adjust_date: date))
    end
  }

  # scope :by_adjust_date, lambda { |start_date, end_date|
  #   if start_date && end_date
  #     where("user_a_adjust_date >= ? AND user_a_adjust_date <= ?", start_date, end_date)
  #       .or(
  #         where("user_b_adjust_date >= ? AND user_b_adjust_date <= ?", start_date, end_date)
  #       )
  #   elsif start_date && !end_date
  #     where("user_a_adjust_date >= ?", start_date)
  #       .or(
  #         where("user_b_adjust_date >= ?", start_date)
  #       )
  #   elsif !start_date && end_date
  #     where("user_a_adjust_date <= ?", end_date)
  #       .or(
  #         where("user_b_adjust_date <= ?", end_date)
  #       )
  #   end
  # }

  scope :by_apply_type, lambda { |type|
    where(apply_type: type) if type
  }

  scope :by_is_deleted, lambda { |is_deleted|
    # if is_deleted == nil || is_deleted == false || is_deleted == 'false' || is_deleted == 'null'
    #   where(is_deleted: false).or(where(is_deleted: nil))
    # end

    unless (is_deleted == 'true' || is_deleted == true)
      where(is_deleted: false).or(where(is_deleted: nil))
    end
  }

  def self.return_attend_state_type(ar_id)
    ar = AdjustRosterRecord.find(ar_id)
    if ar.apply_type == 'for_class' && ar.is_director_special_approval != true
      'adjust_roster'
    elsif ar.apply_type == 'for_holiday' && ar.is_director_special_approval != true
      'adjust_holiday'
    elsif ar.apply_type == 'for_class' && ar.is_director_special_approval == true
      'adjust_roster_with_special'
    elsif ar.apply_type == 'for_holiday' && ar.is_director_special_approval == true
      'adjust_holiday_with_special'
    end
  end

  def self.return_statistics_for(user_id, start_date, end_date)
    # As a

    true_records = AdjustRosterRecord.where(is_deleted: false).or(where(is_deleted: nil))
    as_a = true_records.where(user_a_id: user_id, user_a_adjust_date: start_date..end_date)
    as_a_and_special = as_a.where(is_director_special_approval: true)
    as_a_and_not_special = as_a.where(is_director_special_approval: false)

    as_a_and_special_and_for_class = as_a_and_special.where(apply_type: 'for_class')
    as_a_and_special_count = as_a_and_special.count
    as_a_and_special_and_for_class_count = as_a_and_special_and_for_class.count
    as_a_and_special_and_for_holiday_count = as_a_and_special_count - as_a_and_special_and_for_class_count

    as_a_and_not_special_and_for_class = as_a_and_not_special.where(apply_type: 'for_class')
    as_a_and_not_special_count = as_a_and_not_special.count
    as_a_and_not_special_and_for_class_count = as_a_and_not_special_and_for_class.count
    as_a_and_not_special_and_for_holiday_count = as_a_and_not_special_count - as_a_and_not_special_and_for_class_count

    # As b
    as_b = true_records.where(user_b_id: user_id, user_b_adjust_date: start_date..end_date)
    as_b_and_special = as_b.where(is_director_special_approval: true)
    as_b_and_not_special = as_b.where(is_director_special_approval: false)

    as_b_and_special_and_for_class = as_b_and_special.where(apply_type: 'for_class')
    as_b_and_special_count = as_b_and_special.count
    as_b_and_special_and_for_class_count = as_b_and_special_and_for_class.count
    as_b_and_special_and_for_holiday_count = as_b_and_special_count - as_b_and_special_and_for_class_count

    as_b_and_not_special_and_for_class = as_b_and_not_special.where(apply_type: 'for_class')
    as_b_and_not_special_count = as_b_and_not_special.count
    as_b_and_not_special_and_for_class_count = as_b_and_not_special_and_for_class.count
    as_b_and_not_special_and_for_holiday_count = as_b_and_not_special_count - as_b_and_not_special_and_for_class_count

    not_special = as_a_and_not_special_count + as_b_and_not_special_count
    special = as_a_and_special_count + as_b_and_special_count

    not_special_for_class = as_a_and_not_special_and_for_class_count + as_b_and_not_special_and_for_class_count
    not_special_for_holiday = as_a_and_not_special_and_for_holiday_count + as_b_and_not_special_and_for_holiday_count

    special_for_class = as_a_and_special_and_for_class_count + as_b_and_special_and_for_class_count
    special_for_holiday = as_a_and_special_and_for_holiday_count + as_b_and_special_and_for_holiday_count

    {
      not_special: not_special,
      not_special_for_class: not_special_for_class,
      not_special_for_holiday: not_special_for_holiday,
      special: special,
      special_for_class: special_for_class,
      special_for_holiday: special_for_holiday
    }
  end
end
