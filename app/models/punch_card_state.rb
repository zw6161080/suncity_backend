# == Schema Information
#
# Table name: punch_card_states
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  profile_id     :integer
#  is_need        :boolean
#  is_effective   :boolean
#  effective_date :date
#  start_date     :date
#  end_date       :date
#  creator_id     :integer
#  source_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  is_current     :boolean
#
# Indexes
#
#  index_punch_card_states_on_creator_id  (creator_id)
#  index_punch_card_states_on_user_id     (user_id)
#

class PunchCardState < ApplicationRecord
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"

  has_many :histories, class_name: 'PunchCardState', foreign_key: 'source_id'

  def self.create_with_params(user_id, punch_card_state_params)
    pcs = PunchCardState.create(punch_card_state_params)
    pcs.user_id = user_id
    time_now = Time.zone.now.to_date
    effective_date = pcs.effective_date

    effective_date = effective_date ? effective_date : time_now

    pcs.is_effective = effective_date <= time_now
    # pcs.effective_date = time_now
    pcs.start_date = effective_date
    pcs.save!

    if effective_date <= time_now
      # current = pcs.histories.order(created_at: :desc).first

      # if current
      #   # current.end_date = time_now
      #   current.end_date = pcs.start_date
      #   current.save!
      # end

      pcs.histories.create(
        pcs.attributes.merge({ id: nil, created_at: nil, updated_at: nil, is_current: true })
      )
    end

  end

  def self.create_default_one(user_id)
    time_now = Time.zone.now.to_date
    pcs = PunchCardState.create(user_id: user_id,
                                is_need: true,
                                is_effective: true,
                                effective_date: time_now,
                                start_date: time_now)
    pcs.histories.create(
      pcs.attributes.merge({ id: nil, created_at: nil, updated_at: nil, is_current: true })
    )
    pcs
  end

  def self.auto_update
    PunchCardState.where(source_id: nil).each do |pcs|
      time_now = Time.zone.now.to_date
      if pcs.effective_date && pcs.effective_date <= time_now && pcs.is_effective == false
        # pcs.update(is_effective: true)
        pcs.is_effective = true
        pcs.save

        current = pcs.histories.order(created_at: :desc).first
        if current
          # current.end_date = time_now
          current.end_date = pcs.effective_date
          current.is_current = false
          current.save!
        end

        pcs.histories.create(
          pcs.attributes.merge({ id: nil, created_at: nil, updated_at: nil, is_current: true })
        )
      end
    end
  end

  def self.update_attend_states(pcs)
    ros = RosterObject.where(user_id: pcs.user_id, is_active: ['active', nil]).where("roster_date >= ?", pcs.effective_date)
    ros.each do |ro|
      RosterObject.update_attend_and_states(ro)
    end
  end
end
