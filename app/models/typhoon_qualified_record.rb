# == Schema Information
#
# Table name: typhoon_qualified_records
#
#  id                 :integer          not null, primary key
#  region             :string
#  typhoon_setting_id :integer
#  user_id            :integer
#  is_compensate      :boolean
#  qualify_date       :date
#  money              :integer
#  is_apply           :boolean
#  working_hours      :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_typhoon_qualified_records_on_typhoon_setting_id  (typhoon_setting_id)
#  index_typhoon_qualified_records_on_user_id             (user_id)
#

class TyphoonQualifiedRecord < ApplicationRecord
  belongs_to :user
  belongs_to :typhoon_setting

  scope :by_typhoon_setting_id, lambda { |typhoon_setting_id|
    where(typhoon_setting_id: typhoon_setting_id) if typhoon_setting_id
  }

  scope :by_department_id, lambda { |department_id|
    if department_id
      joins(:user).where(users: { department_id: department_id })
    end
  }

  scope :by_user, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  scope :by_is_apply, lambda { |is_apply|
    where(is_apply: is_apply) if is_apply
  }

  scope :by_qualify_date, lambda { |start_date, end_date|
    if start_date && end_date
      where(qualify_date: start_date .. end_date)
    elsif start_date && !end_date
      where("qualify_date >= ?", start_date)
    elsif !start_date && end_date
      where("qualify_date <= ?", end_date)
    end
  }

  scope :by_typhoon_start_date, lambda { |start_date, end_date|
    if start_date && end_date
      typhoon_setting_ids = TyphoonSetting.where(start_date: start_date .. end_date).pluck(:id)
      where(typhoon_setting_id: typhoon_setting_ids)
    elsif start_date && !end_date
      typhoon_setting_ids = TyphoonSetting.where("start_date >= ?", start_date).pluck(:id)
      where(typhoon_setting_id: typhoon_setting_ids)
    elsif !start_date && end_date
      typhoon_setting_ids = TyphoonSetting.where("start_date <= ?", end_date).pluck(:id)
      where(typhoon_setting_id: typhoon_setting_ids)
    end
  }

  def self.deal_with_compensation(start_d, end_d, result)
    records = TyphoonQualifiedRecord.where(qualify_date: start_d .. end_d, is_compensate: true)

    records.each do |r|
      r.is_compensate = result
      r.save!
    end
  end
end
