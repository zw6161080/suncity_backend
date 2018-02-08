# == Schema Information
#
# Table name: medical_reimbursements
#
#  id                   :integer          not null, primary key
#  reimbursement_year   :integer
#  user_id              :integer
#  apply_date           :datetime         not null
#  medical_template_id  :integer
#  medical_item_id      :integer
#  document_number      :string           not null
#  document_amount      :decimal(10, 2)   not null
#  reimbursement_amount :decimal(10, 2)   not null
#  tracker_id           :integer
#  track_date           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_medical_reimbursements_on_medical_item_id      (medical_item_id)
#  index_medical_reimbursements_on_medical_template_id  (medical_template_id)
#  index_medical_reimbursements_on_tracker_id           (tracker_id)
#  index_medical_reimbursements_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_01a2ea3f8a  (medical_item_id => medical_items.id)
#  fk_rails_4159c5fe93  (user_id => users.id)
#  fk_rails_50d165c389  (medical_template_id => medical_templates.id)
#  fk_rails_d8f1595b17  (tracker_id => users.id)
#

class MedicalReimbursement < ApplicationRecord
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :medical_template, :class_name => 'MedicalTemplate', :foreign_key => 'medical_template_id'
  belongs_to :medical_item, :class_name => 'MedicalItem', :foreign_key => 'medical_item_id'
  belongs_to :tracker, :class_name => 'User', :foreign_key => 'tracker_id'
  has_many :attachment_items, as: :attachable

  validates :apply_date, :document_number, :document_amount, :reimbursement_amount, presence: true

  def self.query_medical_conditions(year, medical_item_id, user_id)
    user = User.find(user_id)
    medical_item = MedicalItem.find(medical_item_id)
    reimbursement_times = medical_item.reimbursement_times
    reimbursement_amount_limit = medical_item.reimbursement_amount_limit
    reimbursement_amount = medical_item.reimbursement_amount
    has_used_reimbursement_times = user.medical_reimbursements.where(reimbursement_year: year, medical_item_id: medical_item_id).count
    has_used_reimbursement_amount = user.medical_reimbursements.where(reimbursement_year: year, medical_item_id: medical_item_id).sum(:reimbursement_amount)
    left_reimbursement_times = reimbursement_times - has_used_reimbursement_times
    left_reimbursement_amount = reimbursement_amount - has_used_reimbursement_amount
    {
      reimbursement_times: reimbursement_times,
      reimbursement_amount_limit: reimbursement_amount_limit,
      reimbursement_amount: reimbursement_amount,
      has_used_reimbursement_times: has_used_reimbursement_times,
      has_used_reimbursement_amount: has_used_reimbursement_amount,
      left_reimbursement_times: left_reimbursement_times < 0 ? BigDecimal(0) : left_reimbursement_times ,
      left_reimbursement_amount: left_reimbursement_amount < 0 ? BigDecimal(0) : left_reimbursement_amount
    }
  end

  def self.detail_by_id(id)
    MedicalReimbursement.includes(:user, :medical_item, :attachment_items).find(id)
  end

  def self.field_options
    user_query           = self.left_outer_joins(user: [:position, :department])
    reimbursement_years  = user_query.select('reimbursement_year').distinct.pluck('reimbursement_year').as_json
    positions            = user_query.select('positions.*').distinct.as_json
    departments          = user_query.select('departments.*').distinct.as_json
    medical_item_ids     = user_query.select('medical_item_id').distinct.pluck('medical_item_id').as_json
    tracker_ids          = user_query.select('tracker_id').distinct.pluck('tracker_id').as_json
    medical_template_ids    = user_query.select('medical_template_id').distinct.pluck('medical_template_id')
    return {
        medical_templates: MedicalTemplate.where(id: medical_template_ids),
        reimbursement_years: reimbursement_years,
        positions: positions,
        departments: departments,
        insurance_types: ['medical_template.enum_insurance_type.suncity_insurance', 'medical_template.enum_insurance_type.commercial_insurance'],
        medical_items: MedicalItem.includes(:medical_item_template).find(medical_item_ids).as_json(include: [:medical_template, :medical_item_template]),
        trackers: User.find(tracker_ids),
    }
  end

  def get_json_data
    data = self.as_json(include: { user: { include: [:department, :position]}, medical_template: {}})
    data['insurance_type'] = MedicalTemplate.find(self.medical_template_id)['insurance_type']
    data['medical_item_template'] = MedicalItemTemplate.find(MedicalItem.find(self.medical_item_id)['medical_item_template_id'])
    data['tracker'] = User.find(self.tracker_id)
    data['attachment_items'] = self
                               .attachment_items
                               .order(:created_at => :desc)
    data
  end
  scope :by_medical_template_id, lambda { |medical_template_id|
    where(medical_template_id: medical_template_id)
  }

  scope :by_reimbursement_year, lambda { |year|
    where(reimbursement_year: year)
  }

  scope :by_employee_no, lambda { |empoid|
    where(users: {empoid: empoid})
  }

  scope :by_department_id, lambda { |department_id|
    where(users: {department_id: department_id})
  }

  scope :by_position_id, lambda { |position_id|
    where(users: {position_id: position_id})
  }

  scope :by_insurance_type, lambda { |insurance_type|
    where(medical_templates: {insurance_type: insurance_type})
  }

  scope :by_medical_item_id, lambda { |medical_item_id|
    where(medical_item_id: medical_item_id)
  }

  scope :by_document_number, lambda { |document_number|
    where(document_number: document_number)
  }

  scope :by_document_amount, lambda { |document_amount|
    where(document_amount: document_amount)
  }

  scope :by_reimbursement_amount, lambda { |reimbursement_amount|
    where(reimbursement_amount: reimbursement_amount)
  }

  scope :by_tracker_id, lambda { |tracker_id|
    where(tracker_id: tracker_id)
  }

end
