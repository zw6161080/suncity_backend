# == Schema Information
#
# Table name: roster_model_states
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  profile_id      :integer
#  roster_model_id :integer
#  is_effective    :boolean
#  effective_date  :date
#  start_date      :date
#  end_date        :date
#  start_week_no   :integer
#  current_week_no :integer
#  source_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  is_current      :boolean
#
# Indexes
#
#  index_roster_model_states_on_roster_model_id  (roster_model_id)
#  index_roster_model_states_on_user_id          (user_id)
#

class RosterModelState < ApplicationRecord
  belongs_to :user
  belongs_to :roster_model
  # has_one :roster_model

  has_many :histories, class_name: 'RosterModelState', foreign_key: 'source_id'


  scope :by_in_service, lambda{|search_date|
    search_date = Time.zone.parse(search_date).to_date rescue nil
    if search_date
      where("start_date <= :search_date AND (end_date >= :search_date OR end_date IS NULL)", search_date: search_date)
    end
  }

  def self.create_with_params(user_id, roster_model_state_params)
    rms = RosterModelState.create(roster_model_state_params)
    rms.user_id = user_id
    # rms.current_week_no = rms.start_week_no
    time_now = Time.zone.now.to_date
    start_date = rms.start_date
    # end_date = rms.end_date
    # start_date = start_date ? start_date : time_now
    # end_date = end_date ? end_date : time_now

    # rms.is_effective = effective_date <= time_now
    # rms.effective_date = time_now
    # rms.start_date = effective_date

    rms.save!

    if start_date <= time_now
      start_week_no = rms.start_week_no
      roster_m = RosterModel.find_by(id: rms.roster_model_id)
      weeks_count = roster_m.weeks_count if roster_m

      if start_week_no && weeks_count
        w_count = (start_date .. time_now).reduce(0) do |sum, d|
          sum = (d.wday == 1 && d != start_date) ? sum + 1 : sum
          sum
        end

        current_week_no_should = (start_week_no + w_count) % weeks_count
        rms.current_week_no = current_week_no_should == 0 ? weeks_count : current_week_no_should
        rms.save!
      end
    end
  end

  def current_week_no_for_query_date(time_now)
    start_week_no = self.start_week_no
    roster_m = RosterModel.find_by(id: self.roster_model_id)
    weeks_count = roster_m.weeks_count if roster_m
    self.calc_current_week_no(time_now,start_week_no, weeks_count) if start_week_no && weeks_count
  end

  def update_current_week_no(rms, time_now = nil)
    time_now =  time_now  || Time.zone.now.to_date
    if self.effective_date && self.effective_date.in_time_zone.to_date <= time_now && self.is_effective == false
      # self.update(is_effective: true, current_week_no: self.start_week_no)
      self.is_effective = true
      self.save
      self.set_current_week_no(time_now)
      self.set_current_history_attribute
      self.create_histories
    end
  end

  def set_current_week_no(time_now)
    start_week_no = self.start_week_no
    roster_m = RosterModel.find_by(id: self.roster_model_id)
    weeks_count = roster_m.weeks_count if roster_m

    if start_week_no && weeks_count
      self.current_week_no = self.calc_current_week_no(time_now,start_week_no, weeks_count)
      self.save
    end
  end

  def calc_current_week_no(time_now, start_week_no, weeks_count)
    w_count = (self.start_date .. time_now.to_date).reduce(0) do |sum, d|
      sum = (d.wday == 1 && d != self.start_date) ? sum + 1 : sum
      sum
    end
    current_week_no_should = (start_week_no + w_count) % weeks_count
    current_week_no_should == 0 ? weeks_count : current_week_no_should
  end

  def set_current_history_attribute
    current = self.histories.order(created_at: :desc).first
    if current
      # current.end_date = time_now
      current.end_date = self.effective_date
      current.is_current = false
      current.save
    end
  end

  def create_histories
    self.histories.create(
      self.attributes.merge({ id: nil, created_at: nil, updated_at: nil, is_current: true })
    )
  end

  def self.auto_update
    RosterModelState.where(source_id: nil).each do |rms|
      time_now = Time.zone.now.to_date
      rms.update_current_week_no(time_now)
    end
  end

  def self.update_current_week_no
    RosterModelState.where(source_id: nil).each do |rms|
      # rms = state.histories.order(created_at: :desc).first
      if rms
        start_week_no = rms.start_week_no
        roster_m = RosterModel.find_by(id: rms.roster_model_id)
        weeks_count = roster_m.weeks_count if roster_m

        start_date = rms.start_date
        rms.current_week_no = nil
        rms.save

        next_rms = RosterModelState.where(user_id: rms.user_id, source_id: nil).where("start_date > ?", start_date).order("start_date desc")&.last
        now_end_date = rms&.end_date&.to_date
        next_start = next_rms&.start_date&.to_date
        end_date = now_end_date ? now_end_date : (next_start ? next_start - 1.day : nil)

        time_now = Time.zone.now.to_date

        if start_date <= time_now
          if (end_date == nil || (end_date && end_date >= time_now))
            if start_week_no && weeks_count
              w_count = (start_date .. time_now).reduce(0) do |sum, d|
                sum = (d.wday == 1 && d != start_date) ? sum + 1 : sum
                sum
              end

              current_week_no_should = (start_week_no + w_count) % weeks_count
              rms.current_week_no = current_week_no_should == 0 ? weeks_count : current_week_no_should
              rms.save!
            end

          elsif end_date && end_date < time_now
            if start_week_no && weeks_count
              w_count = (start_date .. end_date).reduce(0) do |sum, d|
                sum = (d.wday == 1 && d != start_date) ? sum + 1 : sum
                sum
              end

              current_week_no_should = (start_week_no + w_count) % weeks_count
              rms.current_week_no = current_week_no_should == 0 ? weeks_count : current_week_no_should
              rms.save!
            end
          end
        end

      end
    end
  end
end
