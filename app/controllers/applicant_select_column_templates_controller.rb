class ApplicantSelectColumnTemplatesController < ApplicationController
  include SelectColumnTemplateControllerAble

  def create
    template = self.resource_class.new(select_column_template_params)
    template.save!

    response_json
  end
  
  def resource_class
    ApplicantSelectColumnTemplate
  end
end
