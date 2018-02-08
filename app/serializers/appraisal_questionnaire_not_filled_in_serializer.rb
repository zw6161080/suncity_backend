class AppraisalQuestionnaireNotFilledInSerializer < ActiveModel::Serializer
  attributes *User.column_names, :count, :position, :location, :department

  belongs_to :position
  belongs_to :location
  belongs_to :department


  def count
    query = object.appraisal_questionnaires.joins(:questionnaire)
    {
      count_of_to_be_assessed: query.count,
      count_of_not_submit: query.where(:questionnaires => { is_filled_in: false }).count,
      count_of_submited: query.where(:questionnaires => { is_filled_in: true }).count
    }

  end

  def location
    object.location
  end

  def department
    object.department
  end

  def position
    object.position
  end
end
