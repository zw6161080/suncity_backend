# coding: utf-8
# == Schema Information
#
# Table name: card_profiles
#
#  id                         :integer          not null, primary key
#  empo_chinese_name          :string
#  empo_english_name          :string
#  empoid                     :string
#  entry_date                 :date
#  sex                        :string
#  nation                     :string
#  status                     :string
#  approved_job_name          :string
#  approved_job_number        :string
#  allocation_company         :string
#  allocation_valid_date      :date
#  approval_id                :string
#  report_salary_count        :integer
#  report_salary_unit         :string
#  labor_company              :string
#  date_to_submit_data        :date
#  certificate_type           :string
#  certificate_id             :string
#  date_to_submit_certificate :date
#  date_to_stamp              :date
#  date_to_submit_fingermold  :date
#  card_id                    :string
#  cancel_date                :date
#  original_user              :string
#  comment                    :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  new_approval_valid_date    :date
#  new_or_renew               :string
#  certificate_valid_date     :date
#  date_to_get_card           :date
#  card_valid_date            :date
#  photo_id                   :string
#  user_id                    :integer
#
# Indexes
#
#  index_card_profiles_on_user_id  (user_id)
#

class CardProfile < ApplicationRecord
  has_many :card_histories
  has_many :card_attachments
  has_many :card_records
  belongs_to :user
  after_create :after_create_send_message
  after_update :after_update_send_message

  def self.auto_send_message(current_card_id = nil)
    if current_card_id
      cardprofile = CardProfile.where(id: current_card_id).all
    else
      cardprofile = CardProfile.all
    end
    cardprofile.each do |card_profile|
      blue_card_group_users = Role.find_by(key: 'blue_card_group')&.users
      if card_profile.certificate_valid_date && (Time.zone.now.to_date + 60.day) >= card_profile.certificate_valid_date
        Message.add_task(card_profile, "60days_certificate_valid_date", blue_card_group_users.pluck(:id).uniq) unless (blue_card_group_users.nil? || blue_card_group_users.empty?)
      end
      if card_profile.date_to_submit_fingermold && (Time.zone.now.to_date + 2.day) >= card_profile.date_to_submit_fingermold
        Message.add_task(card_profile, "2days_date_to_submit_fingermold", blue_card_group_users.pluck(:id).uniq) unless (blue_card_group_users.nil? || blue_card_group_users.empty?)
      end
      if card_profile.date_to_get_card && (Time.zone.now.to_date + 5.day) >= card_profile.date_to_get_card
        Message.add_task(card_profile, "5days_date_to_get_card", blue_card_group_users.pluck(:id).uniq) unless (blue_card_group_users.nil? || blue_card_group_users.empty?)
      end
      if card_profile.card_valid_date && (Time.zone.now.to_date + 90.day) >= card_profile.card_valid_date
        Message.add_task(card_profile, "90days_card_valid_date", blue_card_group_users.pluck(:id).uniq) unless (blue_card_group_users.nil? || blue_card_group_users.empty?)
      end
      if card_profile.allocation_valid_date && (Time.zone.now.to_date + 60.day) >= card_profile.allocation_valid_date && (Time.zone.now.to_date + 30.day) < card_profile.allocation_valid_date
        Message.add_task(card_profile, "60days_allocation_valid_date", blue_card_group_users.pluck(:id).uniq) unless (blue_card_group_users.nil? || blue_card_group_users.empty?)
      end
      if card_profile.allocation_valid_date && (Time.zone.now.to_date + 30.day) >= card_profile.allocation_valid_date
        Message.add_task(card_profile, "30days_allocation_valid_date", blue_card_group_users.pluck(:id).uniq) unless (blue_card_group_users.nil? || blue_card_group_users.empty?)
      end
      if card_profile.new_approval_valid_date && (Time.zone.now.to_date + 90.day) >= card_profile.new_approval_valid_date
        Message.add_task(card_profile, "90days_new_approval_valid_date", blue_card_group_users.pluck(:id).uniq) unless (blue_card_group_users.nil? || blue_card_group_users.empty?)
      end
    end
  end

  def after_create_send_message
    CardProfile.auto_send_message(self.id)
  end

  def after_update_send_message
    CardProfile.auto_send_message(self.id)
  end

end
