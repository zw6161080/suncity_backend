# == Schema Information
#
# Table name: transfer_position_apply_by_departments
#
#  id                                     :integer          not null, primary key
#  region                                 :string
#  user_id                                :integer
#  comment                                :text
#  apply_date                             :date
#  apply_serve_date                       :date
#  apply_location_id                      :integer
#  apply_department_id                    :integer
#  apply_position_id                      :integer
#  transfer_position_reason_by_department :text
#  is_agreed_by_employee                  :boolean
#  employee_opinion                       :text
#  is_hired                               :boolean
#  need_pass_trial                        :boolean
#  hire_position_id                       :integer
#  effective_date                         :date
#  department_comment                     :text
#  is_transfer                            :boolean
#  transfer_date                          :date
#  transfer_location_id                   :integer
#  transfer_department_id                 :integer
#  transfer_position_id                   :integer
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  salary_record                          :jsonb
#  new_salary_record                      :jsonb
#  welfare_record                         :jsonb
#  new_welfare_record                     :jsonb
#  salary_calculation                     :string
#  apply_group_id                         :integer
#  transfer_group_id                      :integer
#
# Indexes
#
#  tp_apply_department_index_111  (apply_department_id)
#  tp_apply_group_index           (apply_group_id)
#  tp_apply_location_index        (apply_location_id)
#  tp_apply_position_index        (apply_position_id)
#  tp_transfer_department_index   (transfer_department_id)
#  tp_transfer_group_index        (transfer_group_id)
#  tp_transfer_location_index     (transfer_location_id)
#  tp_transfer_position_index     (transfer_position_id)
#  tp_user_index                  (user_id)
#

class TransferPositionApplyByDepartment < ApplicationRecord
  include JobTransferAble
  belongs_to :user, required: true
  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy
  has_many :job_transfers, as: :transferable
  belongs_to :transfer_location, class_name: 'Location', foreign_key: :transfer_location_id
  belongs_to :transfer_department, class_name: 'Department', foreign_key: :transfer_department_id
  belongs_to :transfer_position, class_name: 'Position', foreign_key: :transfer_position_id
  belongs_to :apply_location, class_name: 'Location', foreign_key: :apply_location_id
  belongs_to :apply_department, class_name: 'Department', foreign_key: :apply_department_id
  belongs_to :apply_position, class_name: 'Position', foreign_key: :apply_position_id
  belongs_to :apply_group, class_name: 'Group', foreign_key: :apply_group_id
  belongs_to :transfer_group, class_name: 'Group', foreign_key: :transfer_group_id
end
