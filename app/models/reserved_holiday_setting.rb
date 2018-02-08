# == Schema Information
#
# Table name: reserved_holiday_settings
#
#  id                  :integer          not null, primary key
#  can_destroy         :boolean
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  date_begin          :datetime
#  date_end            :datetime
#  days_count          :integer
#  member_count        :integer
#  comment             :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :integer
#  update_date         :datetime
#
# Indexes
#
#  index_reserved_holiday_settings_on_creator_id  (creator_id)
#
# Foreign Keys
#
#  fk_rails_a91ef09453  (creator_id => users.id)
#

class ReservedHolidaySetting < ApplicationRecord

  include StatementAble

  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  has_many :reserved_holiday_participators, dependent: :destroy

  validates :chinese_name, :english_name, :simple_chinese_name, :date_begin, :date_end, :days_count, :creator_id, presence: { message: "%{value} must be given." }

  def update_member_count
    member_count = self.reserved_holiday_participators.count
    self.update(member_count: member_count)
    self.save
  end

  class << self
    def joined_query(param_id = nil)
      self.left_outer_joins(
        [:creator]
      )
    end

    def extra_query_params
      # 在Model中Override該方法，提供需要額外支持的搜索參數, eg:
      # [ { key: 'day_example', search_type: 'day_range' }, { key: 'value_example' } ]
      [
        { key: 'date_begin', search_type: 'day_range' },
        { key: 'date_end',   search_type: 'day_range' }
      ]
    end

  end

  scope :by_name, -> (name) {
    where('reserved_holiday_settings.chinese_name = :name OR reserved_holiday_settings.english_name = :name', name: name)
  }

  scope :by_date_begin, -> (date_begin) {
    from = Time.zone.parse(date_begin[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_begin[:end]).end_of_day rescue nil
    if from && to
      where("date_begin >= :from", from: from).where("date_begin <= :to", to: to)
    elsif from
      where("date_begin >= :from", from: from)
    elsif to
      where("date_begin <= :to", to: to)
    end
  }

  scope :by_date_end, -> (date_end) {
    from = Time.zone.parse(date_end[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_end[:end]).end_of_day rescue nil
    if from && to
      where("date_end >= :from", from: from).where("date_end <= :to", to: to)
    elsif from
      where("date_end >= :from", from: from)
    elsif to
      where("date_end <= :to", to: to)
    end
  }

  scope :by_days_count, -> (days_count) {
    where(days_count: days_count) if days_count
  }

  scope :by_member_count, -> (member_count) {
    where(member_count: member_count) if member_count
  }

  scope :by_creator, -> (name) {
    where(creator_id: User.where('users.chinese_name = :name OR users.english_name = :name', name: name).select(:id)) if name
  }

  scope :by_update_date, -> (update_date) {
    from = Time.zone.parse(update_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(update_date[:end]).end_of_day rescue nil
    if from && to
      where("update_date >= :from", from: from).where("update_date <= :to", to: to)
    elsif from
      where("update_date >= :from", from: from)
    elsif to
      where("update_date <= :to", to: to)
    end
  }

  scope :order_by, -> (sort_column, sort_direction) {
    if sort_column == :creator
      order("users.chinese_name #{sort_direction}")
    elsif sort_column == :name
      order(:chinese_name => sort_direction)
    else
      order(sort_column => sort_direction)
    end
  }

end
