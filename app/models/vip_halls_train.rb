# == Schema Information
#
# Table name: vip_halls_trains
#
#  id                            :integer          not null, primary key
#  location_id                   :integer
#  train_month                   :datetime
#  locked                        :boolean
#  employee_amount               :integer
#  training_minutes_available    :integer
#  training_minutes_accepted     :integer
#  training_minutes_per_employee :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_vip_halls_trains_on_location_id  (location_id)
#
# Foreign Keys
#
#  fk_rails_72d5c43a0b  (location_id => locations.id)
#

class VipHallsTrain < ApplicationRecord
  belongs_to :location, :class_name => 'Location', :foreign_key => 'location_id'

  def self.auto_update_employee_amount
    VipHallsTrain.where(locked: false).each do |record|
      record.employee_amount               = User.where(location_id: record.location_id).count
      record.training_minutes_available    = VipHallsTrainer
                                                 .where(vip_halls_train_id: record.id)
                                                 .pluck('length_of_training_time')
                                                 .sum
      record.training_minutes_accepted     = VipHallsTrainer
                                                 .where(vip_halls_train_id: record.id)
                                                 .pluck('total_accepted_training_time')
                                                 .sum
      record.training_minutes_per_employee = (record.training_minutes_accepted/record.employee_amount).to_i rescue 0
      record.save!
    end
  end

  def self.options
    query = self.left_outer_joins(:location)
    train_months = query.select('train_month').distinct.pluck('train_month').map do |item|
      item.strftime('%Y/%m')
    end
    locations = query.select('locations.*').distinct.as_json
    return {
        train_months: train_months,
        locations: locations
    }
  end

  def get_json_data
    data = self.as_json(include: :location)
    data
  end

  scope :by_location_id, lambda { |location_id|
    where(location_id: location_id)
  }

  scope :by_train_month, lambda { |train_month|
    where(train_month: Time.zone.parse(train_month))
  }

end
