# == Schema Information
#
# Table name: appraisal_for_departments
#
#  id                                :integer          not null, primary key
#  appraisal_id                      :integer
#  department_id                     :integer
#  participator_amount_in_department :integer
#  ave_total_appraisal_in_department :decimal(5, 2)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
# Indexes
#
#  index_appraisal_for_departments_on_appraisal_id   (appraisal_id)
#  index_appraisal_for_departments_on_department_id  (department_id)
#
# Foreign Keys
#
#  fk_rails_59f33b88e2  (appraisal_id => appraisals.id)
#  fk_rails_bf5b8f7a7f  (department_id => departments.id)
#

class AppraisalForDepartment < ApplicationRecord
  belongs_to :appraisal
  belongs_to :department

  def get_json_data
    data = self.as_json(include: :appraisal)
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
    where(participator_amount_in_department: participator_amount_in_department)
  }

  scope :by_ave_total_appraisal_in_department, ->(ave_total_appraisal_in_department) {
    where(ave_total_appraisal_in_department: ave_total_appraisal_in_department)
  }

end
