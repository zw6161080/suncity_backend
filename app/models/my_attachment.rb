# == Schema Information
#
# Table name: my_attachments
#
#  id               :integer          not null, primary key
#  status           :string
#  download_process :decimal(15, 2)   default(0.0)
#  file_name        :string
#  attachment_id    :integer
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_my_attachments_on_attachment_id  (attachment_id)
#  index_my_attachments_on_user_id        (user_id)
#

class MyAttachment < ApplicationRecord
  belongs_to :user
  belongs_to :attachment
  validates :user_id, presence: true
  after_save :broadcast_process, unless: :has_completed?

  scope :by_query_key, lambda{|query_key|
    query_key_by_datetime = Time.zone.parse(query_key) rescue nil
    if query_key && query_key_by_datetime
      where("file_name ilike :query_key OR (created_at >= :query_key_by_datetime_begin AND created_at <= :query_key_by_datetime_end)", query_key: "%#{query_key}%", query_key_by_datetime_begin: query_key_by_datetime.beginning_of_day, query_key_by_datetime_end: query_key_by_datetime.end_of_day)
    elsif query_key
      where("file_name ilike :query_key", query_key: "%#{query_key}%")
    end
  }

  def has_completed?
    self.status == 'completed'
  end

  def broadcast_process
    more_record_count = Rails.cache.fetch("more_record_count_#{self.user_id}", :expires_in => 24.hours) do
      1
    end
    search_key = Rails.cache.fetch("search_key_#{self.user_id}", :expires_in => 24.hours)
    res = self.user.all_index(more_record_count: more_record_count, search_key: search_key)
    all_index = ActiveModelSerializers::SerializableResource.new(res[:query], root: :data, meta: res[:meta])
    ActionCable.server.broadcast "#{self.user_id}_my_attachment", head_index: self.user.my_attachments.limit(5).order(created_at: :desc),
      all_index: all_index
  end




end
