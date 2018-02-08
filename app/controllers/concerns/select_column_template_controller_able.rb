module SelectColumnTemplateControllerAble
  def index
    region = params[:region]
    templates = self.resource_class
                    .where(region: region)
                    .order(default: :desc)
    self.resource_class.generate_default_template(templates,  region)
    response_json templates.as_json(only: [:name, :id, :department_id, :attachType, :default])
  end

  def create
    template = self.resource_class.new(select_column_template_params.merge(:department_id => current_user.department_id))
    template.save!

    response_json
  end

  def show
    template = self.resource_class.find(params[:id])
    response_json template.as_json(methods: :select_columns)
  end

  def update
    template = self.resource_class.find(params[:id])
    region = template.region

    template.update!(select_column_template_params)

    response_json
  end

  def destroy
    template = self.resource_class.find(params[:id])
    region = template.region

    template.delete

    response_json
  end

  def all_selectable_columns
    region = params[:region]
    columns = self.resource_class.all_selectable_columns(region: region)
    response_json columns.as_json
  end

  def all_selectable_columns_with_section
    region = params[:region]
    data = self.resource_class.all_selectable_columns_with_section(region: region)
    response_json data.as_json
  end

  def select_column_template_params
    params.require(self.resource_class.table_name.singularize.to_sym)
          .permit(:region, {:select_column_keys => []}, :name, :attachType, :default)
  end
end
