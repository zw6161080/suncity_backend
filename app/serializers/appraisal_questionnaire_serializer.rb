class AppraisalQuestionnaireSerializer < ActiveModel::Serializer
  attributes *AppraisalQuestionnaire.column_names,
             # :assess_participator,
             :appraisal_participator,
             :questionnaire_template,
             :departmental_appraisal_group
             # :latest_revision_history

  belongs_to :questionnaire
  has_many :revision_histories
  # belongs_to :appraisal_participator
  belongs_to :assessor, :class_name => 'User', :foreign_key => 'assessor_id'

  # def latest_revision_history
  #   object.revision_histories.order(:revision_date => :desc).first
  # end

  def departmental_appraisal_group
    object.appraisal_participator.departmental_appraisal_group
  end

  # def assess_participator
  #   object.assessor.as_json(include: [:location, :department, :position])
  # end

  def appraisal_participator
    object.appraisal_participator.user.as_json(include: [:location, :department, :position])
  end

  def questionnaire_template
    ActiveModelSerializers::SerializableResource.new(object.questionnaire.questionnaire_template, root: 'template',include: '**')
  end

end
