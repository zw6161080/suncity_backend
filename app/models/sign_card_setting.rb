# coding: utf-8
# == Schema Information
#
# Table name: sign_card_settings
#
#  id                  :integer          not null, primary key
#  region              :string
#  code                :string
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  comment             :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class SignCardSetting < ApplicationRecord
  # has_many :children, class_name: 'SignCardReason'
  has_many :sign_card_reasons, -> { order "created_at ASC" }

  private

  def self.is_init?
    self.all.empty?
  end

  def self.start_init_table
    if SignCardSetting.is_init?
      SignCardSetting.init_table.each do |type|
        sign_card_type = SignCardSetting.create(type)
        if type[:code] == '005'
          SignCardReason.init_reason[:others].each do |reason|
            sign_card_type.sign_card_reasons.create(reason)
          end
        elsif type[:code] == '006'
          SignCardReason.init_reason[:typhoon].each do |reason|
            sign_card_type.sign_card_reasons.create(reason)
          end
        end
      end
    end
  end

  def self.init_table
    [
      {
        code: '001',
        chinese_name: '漏打卡上班',
        simple_chinese_name: '漏打卡上班',
        english_name: 'Forget to punch in'
      },

      {
        code: '002',
        chinese_name: '漏打卡下班',
        simple_chinese_name: '漏打卡下班',
        english_name: 'Forget to punch out'
      },

      {
        code: '003',
        chinese_name: '早退',
        simple_chinese_name: '早退',
        english_name: 'Leave early'
      },

      {
        code: '004',
        chinese_name: '外出工作',
        simple_chinese_name: '外出工作',
        english_name: 'Work out'
      },
      {
        code: '005',
        chinese_name: '其他',
        simple_chinese_name: '其他',
        english_name: 'Others'
      },
      {
        code: '006',
        chinese_name: '颱風',
        simple_chinese_name: '台风',
        english_name: 'Typhoon'
      }
    ]
  end

  def self.return_attend_state_type(sign_card_setting_id)
    scs = SignCardSetting.find(sign_card_setting_id)
    raise LogicError, {id: 422, message: '找不到数据'}.to_json unless scs
    if scs['english_name'] == 'Forget to punch in'
      'forget_to_punch_in'
    elsif scs['english_name'] == 'Forget to punch out'
      'forget_to_punch_out'
    elsif scs['english_name'] == 'Leave early'
      'leave_early'
    elsif scs['english_name'] == 'Work out'
      'work_out'
    elsif scs['english_name'] == 'Others'
      'others'
    elsif scs['english_name'] == 'Typhoon'
      'typhoon'
    else
      ''
    end
  end

  def self.set_be_used
    SignCardSetting.all.each do |setting|
      setting.sign_card_reasons.each do |reason|
        be_used = SignCardRecord.where(sign_card_reason_id: reason.id).count > 0
        reason.be_used = be_used
        reason.save!
      end
    end
  end
end
