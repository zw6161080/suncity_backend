# == Schema Information
#
# Table name: medical_items
#
#  id                         :integer          not null, primary key
#  reimbursement_times        :integer
#  reimbursement_amount_limit :decimal(10, 2)
#  reimbursement_amount       :decimal(10, 2)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  medical_item_template_id   :integer
#  medical_template_id        :integer
#
# Indexes
#
#  index_medical_items_on_medical_item_template_id    (medical_item_template_id)
#  index_medical_items_on_medical_template_id         (medical_template_id)
#  index_medical_items_on_reimbursement_amount        (reimbursement_amount)
#  index_medical_items_on_reimbursement_amount_limit  (reimbursement_amount_limit)
#  index_medical_items_on_reimbursement_times         (reimbursement_times)
#
# Foreign Keys
#
#  fk_rails_3aae2d1400  (medical_template_id => medical_templates.id)
#  fk_rails_f4dfe73604  (medical_item_template_id => medical_item_templates.id)
#

class MedicalItem < ApplicationRecord
  belongs_to :medical_template, :class_name => 'MedicalTemplate', :foreign_key => 'medical_template_id'
  belongs_to :medical_item_template, :class_name => 'MedicalItemTemplate', :foreign_key => 'medical_item_template_id'

end
