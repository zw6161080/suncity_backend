# == Schema Information
#
# Table name: month_salary_attachments
#
#  id               :integer          not null, primary key
#  status           :string
#  file_name        :string
#  attachment_id    :integer
#  creator_id       :integer
#  report_type      :string
#  download_process :decimal(15, 2)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_month_salary_attachments_on_attachment_id  (attachment_id)
#

class MonthSalaryAttachment < ApplicationRecord

  belongs_to :attachment, dependent: :destroy
  validates :creator_id, presence: true
  validates :status, inclusion: {in: %w(generating fail to_be_download downloaded)}
  validates :report_type, inclusion: {in: %w(index index_by_left show)}

end
