# == Schema Information
#
# Table name: revise_clock_items
#
#  id                   :integer          not null, primary key
#  revise_clock_id      :integer
#  clock_date           :date
#  clock_in_time        :datetime
#  clock_out_time       :datetime
#  attendance_state     :jsonb
#  new_clock_in_time    :datetime
#  new_clock_out_time   :datetime
#  new_attendance_state :jsonb
#  comment              :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#
# Indexes
#
#  index_revise_clock_items_on_revise_clock_id  (revise_clock_id)
#  index_revise_clock_items_on_user_id          (user_id)
#

class ReviseClockItem < ApplicationRecord
  belongs_to :revise_clock
  has_many :revise_clock_assistants
  after_create :create_revise_clock_assistant
  belongs_to :user
  has_one :roster_item
  include StatementAble

  def create_revise_clock_assistant
    if self.new_clock_in_time
      ReviseClockAssistant.create(revise_clock_item_id:self.id, sign_time: self.new_clock_in_time.to_time.to_s.split[1])
    end
    if self.new_clock_out_time
      ReviseClockAssistant.create(revise_clock_item_id:self.id, sign_time: self.new_clock_out_time.to_time.to_s.split[1])
    end
  end

  def roster_item
    if self.user&& self.user.id && self.clock_date
      RosterItem.by_user(self.user.id).by_date(self.clock_date).as_json(include: :shift)
    end
  end

  scope :left_outer_join_user_and_creator_query_with_typhoon_item, lambda{
    hurricane_work_id = AttendanceState.find_by_code(Config.get(:constants_collection)['AttendanceState']['working_when_typhoon']).id
    left_outer_joins(
        {revise_clock: [{user:[:department, :position]}, :creator]}
    ).where(
        "new_attendance_state @> ?", [].push(hurricane_work_id).to_json
    )
  }

  scope :by_empoid, lambda{|empoid|
    where(users: {empoid: empoid}) if empoid
  }
  scope :by_name, lambda {|name|
    where(users:{select_language => name}) if name
  }
  scope :by_department_id, lambda{|department_id|
    where(departments: {id: department_id})  if department_id
  }
  scope :by_position_id, lambda{|position_id|
    where(positions: {id: position_id}) if position_id
  }
  scope :by_creator_name, lambda{|creator_name|
    where(creators_revise_clocks: {select_language => creator_name})  if creator_name
  }
  scope :by_clock_date, lambda{ |clock_date|
    clock_date_begin = Time.zone.parse(clock_date[:begin]).beginning_of_day  rescue nil
    clock_date_end = Time.zone.parse(clock_date[:begin]).end_of_day rescue nil
      if clock_date_begin && clock_date_end
        where('clock_date > :clock_date_begin && clock_date < :clock_date_end',clock_date_begin: clock_date_begin, clock_date_end: clock_date_end)
      elsif clock_date_begin
        where('clock_date > :clock_date_begin', clock_date_begin: clock_date_begin)
      elsif clock_date_end
        where('clock_date < :clock_date_end', clock_date_end: clock_date_end)
      end
  }

  scope :by_created_at, lambda{ |created_at|
    created_at_begin = Time.zone.parse(created_at[:begin]).beginning_of_day rescue nil
    created_at_end = Time.zone.parse(created_at[:end]).end_of_day rescue nil
    if created_at_begin && created_at_end
      where('created_at > :created_at_begin && created_at < :created_at_end',created_at_begin: created_at_begin, created_at_end: created_at_end)
    elsif created_at_begin
      where('created_at > :created_at_begin', created_at_begin: created_at_begin)
    elsif created_at_end
      where('created_at< :created_at_end', created_at_end: created_at_end)
    end
  }


  scope :order_by, lambda {|sort_column, sort_direction|
    if sort_column == :empoid
      order("users.empoid #{sort_direction}")
    elsif sort_column == :name
      order("users.#{select_language.to_s} #{sort_direction}")
    elsif sort_column == :department_id
      order("departments.id #{sort_direction}")
    elsif sort_column == :position_id
      order("positions.id #{sort_direction}")
    elsif  sort_column == :creator_name
      order("creators_revise_clocks.#{select_language.to_s} #{sort_direction}")
    else
      order(sort_column => sort_direction)
    end
  }
end
