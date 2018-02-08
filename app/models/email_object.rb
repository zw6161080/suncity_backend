# == Schema Information
#
# Table name: email_objects
#
#  id            :integer          not null, primary key
#  to            :jsonb
#  subject       :string
#  body          :text
#  the_object    :string
#  the_object_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status        :integer          default("not_deliveried")
#  mark          :string
#

class EmailObject < ApplicationRecord

  enum status: { not_deliveried: 0, deliveried: 1 }

  def send_now
    self.class.send_email(self)
    self.deliveried!
  end

  def self.send_email(email_object)
    applicant_position = ApplicantPosition.find_by_id(email_object.the_object_id)
    Notice.new.send_mail_obj(applicant_position, email_object).deliver
  end

end
