# coding: utf-8
class AssessmentQuestionnaireItemsController < ApplicationController
  def get_questionnaire_template
    user = User.find(params[:user_id])

    options = if user.grade.to_i < 5
                AssessmentQuestionnaireItem.under_five_options_template
              else
                AssessmentQuestionnaireItem.grade_five_options_template
              end

    normal = AssessmentQuestionnaireItem.normal_options_template

    response_json (options + normal).as_json
  end

end
