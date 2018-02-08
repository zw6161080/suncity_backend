# == Schema Information
#
# Table name: appraisal_participate_departments
#
#  id                  :integer          not null, primary key
#  appraisal_id        :integer
#  location_id         :integer
#  department_id       :integer
#  confirmed           :boolean
#  participator_amount :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_appraisal_participate_departments_on_appraisal_id   (appraisal_id)
#  index_appraisal_participate_departments_on_department_id  (department_id)
#  index_appraisal_participate_departments_on_location_id    (location_id)
#
# Foreign Keys
#
#  fk_rails_1bb8dcf71e  (appraisal_id => appraisals.id)
#  fk_rails_cf0a118d18  (department_id => departments.id)
#  fk_rails_fcff0ff8de  (location_id => locations.id)
#

class AppraisalParticipateDepartment < ApplicationRecord
  belongs_to :appraisal
  belongs_to :location
  belongs_to :department
end
