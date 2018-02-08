# == Schema Information
#
# Table name: appraisal_groups
#
#  id                              :integer          not null, primary key
#  appraisal_department_setting_id :integer
#  name                            :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  index_appraisal_groups_on_appraisal_department_setting_id  (appraisal_department_setting_id)
#

class AppraisalGroup < ApplicationRecord

  belongs_to :appraisal_department_setting
  belongs_to :appraisal_employee_setting
end
