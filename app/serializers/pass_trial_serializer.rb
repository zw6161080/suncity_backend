class PassTrialSerializer < ActiveModel::Serializer
  attributes *PassTrial.column_names, :questionnaire_items
  belongs_to :user
  has_many :attend_attachments
  has_many :approval_items

  def questionnaire_items
    object.assessment_questionnaire.items.order("order_no asc")
  end
end
