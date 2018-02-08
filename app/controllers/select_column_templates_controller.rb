class SelectColumnTemplatesController < ApplicationController
  include SelectColumnTemplateControllerAble

  def resource_class
    SelectColumnTemplate
  end

  def index_by_department
      region = params[:region]
      templates = self.resource_class
                      .where(region: region).where(department_id: current_user.department_id)
                      .order(default: :desc)

      self.resource_class.generate_default_template(templates,  region)
      response_json templates.as_json(only: [:name, :id, :default])

  end

  def create_by_department
    template = self.resource_class.new(select_column_template_params.merge(:department_id => current_user.department_id))
    template.save!

    response_json
  end


end
