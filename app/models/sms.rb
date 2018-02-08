# coding: utf-8
# == Schema Information
#
# Table name: sms
#
#  id            :integer          not null, primary key
#  to            :string
#  content       :text
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status        :integer          default("not_deliveried")
#  title         :string
#  the_object    :string
#  the_object_id :integer
#  mark          :string
#
# Indexes
#
#  index_sms_on_user_id  (user_id)
#

class Sms < ApplicationRecord
  self.table_name = 'sms'

  enum status: { not_deliveried: 0, deliveried: 1 }

  def self.templates(params)
    default_params = {
      applicant_name: " 求职者 ",
      first_interview_time: "［XXXX年XX月XX日 下午XX時XX分］",
      second_interview_time: "［XXXX年XX月XX日 下午XX時XX分］",
      third_interview_time: "［XXXX年XX月XX日 下午XX時XX分］",
      contract_notice_time: "［XXXX年XX月XX日 下午XX時XX分］",
      change_contract_time: "［XXXX年XX月XX日 下午XX時XX分］",
      applicant_no: '［R-XXXXXXXXX］',
      position_name: '［职位名称］',
      contact_phone: '+853 8891 1332'
    }

    params = params.to_h.symbolize_keys
    params = default_params.merge(params)
    templates = Config.get(:sms_templates)
    YAML::load templates.to_yaml % params
  end

  def send_msg
    unless self.content.blank?
      Sms.send_sms(self.to, self.content)
      self.deliveried!
    end
  end

  def self.send_sms(to, content)
    SuncitySmsService.send_msg(to, content)
  end
end
