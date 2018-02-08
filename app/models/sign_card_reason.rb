# coding: utf-8
# == Schema Information
#
# Table name: sign_card_reasons
#
#  id                   :integer          not null, primary key
#  region               :string
#  sign_card_setting_id :integer
#  reason               :string
#  reason_code          :string
#  be_used              :boolean
#  be_used_count        :integer          default(0)
#  comment              :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_sign_card_reasons_on_sign_card_setting_id  (sign_card_setting_id)
#

class SignCardReason < ApplicationRecord
  belongs_to :sign_card_setting

  private

  def self.init_reason
    {
      others: [
        { reason_code: 'a', reason: '不成功記錄' },
        { reason_code: 'b', reason: '工作時間過長' },
        { reason_code: 'c', reason: '指紋未能傳送' },
        { reason_code: 'd', reason: '主管特許上班時間' },
        { reason_code: 'e', reason: '馬尼拉公幹' },
        { reason_code: 'f', reason: '墨爾本公幹' },
        { reason_code: 'g', reason: '越南公幹' },
        { reason_code: 'h', reason: '韓國公幹' },
        { reason_code: 'i', reason: '公司培訓' },
        { reason_code: 'j', reason: '集團晚宴' },
        { reason_code: 'k', reason: '股東春茗' },
        { reason_code: 'l', reason: '自行填寫' }
      ],
      typhoon: [
        { reason_code: 'a', reason: '颱風不當遲到' },
        { reason_code: 'b', reason: '因颱風主管允許不用上班' }
      ]
    }
  end
end
