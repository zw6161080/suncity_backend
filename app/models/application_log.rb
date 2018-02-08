# == Schema Information
#
# Table name: application_logs
#
#  id                    :integer          not null, primary key
#  applicant_position_id :integer
#  user_id               :integer
#  behavior              :string
#  info                  :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_application_logs_on_applicant_position_id  (applicant_position_id)
#  index_application_logs_on_user_id                (user_id)
#

class ApplicationLog < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :applicant_position

  def titles
    {
      applicant_profile_created: '求職者提交申請',
      applicant_profile_updated: '求職者資料更新',

      applicant_position_updated: '求職投遞更新',
      
      audience_created: '接見創建',
      audience_updated: '接見更新',

      interview_created: '面試創建',
      interview_updated: '面試更新',

      interviewer_updated: '面試官操作',

      contract_created: '簽約創建',
      contract_updated: '簽約更新',

      agreement_file_created: '合約文件創建',
      agreement_file_removed: '合約文件移除',

      sms_sent: '短信發送',
      email_sent: '郵件發送'
    }
  end

  def title
    self.titles.fetch(self.behavior.to_sym)
  end

  def behaviors
    self.titles.keys
  end

  def fetch_info(key)
    ''
    self.info.fetch(key, '') if self.info
  end

  def self.add_log(behavior)
    log = self.new
    raise LogicError, { message: "Wrong log behavior!" }.to_json unless log.titles.keys.include? behavior.to_sym
    log.behavior = behavior
    log.info = {}
    yield log
    log.info[:title] = log.title
    log.save
  end

end
