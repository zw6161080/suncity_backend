# == Schema Information
#
# Table name: appraisal_for_users
#
#  id                          :integer          not null, primary key
#  appraisal_id                :integer
#  appraisal_for_department_id :integer
#  user_id                     :integer
#  ave_total_appraisal_self    :decimal(5, 2)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_appraisal_for_users_on_appraisal_for_department_id  (appraisal_for_department_id)
#  index_appraisal_for_users_on_appraisal_id                 (appraisal_id)
#  index_appraisal_for_users_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_0719d47955  (appraisal_for_department_id => appraisal_for_departments.id)
#  fk_rails_bf88970fe7  (appraisal_id => appraisals.id)
#  fk_rails_c2d6ce1a25  (user_id => users.id)
#

class AppraisalForUser < ApplicationRecord
  belongs_to :appraisal
  belongs_to :appraisal_for_department
  belongs_to :user

  def get_json_data
    data = self.as_json(include: [:appraisal, :appraisal_for_department])
    data[:appraisal_date] = "#{self.appraisal.date_begin.strftime('%Y/%m/%d')} ~ #{self.appraisal.date_end.strftime('%Y/%m/%d')}"
    data
  end

  scope :by_appraisal_status, ->(appraisal_status) {
    where(appraisals: {appraisal_status: appraisal_status})
  }

  scope :by_appraisal_date, ->(appraisal_date) {
    from = Time.zone.parse(appraisal_date['begin']).beginning_of_day rescue nil
    to   = Time.zone.parse(appraisal_date['end']).end_of_day rescue nil
    if from && to
      where('appraisals.date_end >= :from AND appraisals.date_begin <= :to', from: from, to: to)
    elsif from
      where('appraisals.date_end >= :from', from: from)
    elsif to
      where('appraisals.date_begin <= :to', to: to)
    end
  }

  scope :by_participator_amount, ->(participator_amount) {
    where(appraisals: {participator_amount: participator_amount})
  }

  scope :by_ave_total_appraisal, ->(ave_total_appraisal) {
    where(appraisals: {ave_total_appraisal: ave_total_appraisal})
  }

  scope :by_participator_amount_in_department, ->(participator_amount_in_department) {
    where(appraisal_for_departments: {participator_amount_in_department: participator_amount_in_department})
  }

  scope :by_ave_total_appraisal_in_department, ->(ave_total_appraisal_in_department) {
    where(appraisal_for_departments: {ave_total_appraisal_in_department: ave_total_appraisal_in_department})
  }

  scope :by_ave_total_appraisal_self, ->(ave_total_appraisal_self) {
    where(ave_total_appraisal_self: ave_total_appraisal_self)
  }

end
