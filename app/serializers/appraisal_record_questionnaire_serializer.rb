class AppraisalRecordQuestionnaireSerializer < ActiveModel::Serializer
  attributes *AppraisalQuestionnaire.column_names,
             :assess_type,
             :assess_participator,
             :appraisal_participator,
             :questionnaire_template,
             :appraisal_date

  belongs_to :questionnaire
  belongs_to :appraisal
  has_many :revision_histories

  def appraisal_date
    "#{object.appraisal.date_begin.strftime('%Y/%m/%d')}~#{object.appraisal.date_end.strftime('%Y/%m/%d')}"
  end

  def assess_participator
    object.assessor.as_json(include: [:location, :department, :position])
  end

  def appraisal_participator
    object.appraisal_participator.user.as_json(include: [:location, :department, :position])
  end

  def questionnaire_template
    ActiveModelSerializers::SerializableResource.new(object.questionnaire.questionnaire_template, root: 'template',include: '**')
  end

end
