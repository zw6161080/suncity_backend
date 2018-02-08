module AttachmentTypeActions

  def index
    profile_attachment_types = model.all.as_json(methods: [:can_delete?, :total_count])
    response_json profile_attachment_types
  end

  def create
    authorize model
    profile_attachment_type = model.create(params.permit(:chinese_name, :english_name, :simple_chinese_name, :description))
    profile_attachment_type.save

    response_json
  end

  def show
    profile_attachment_types = model.find(params[:id])
    response_json profile_attachment_types
  end

  def update
    authorize model
    profile_attachment_types = model.find(params[:id])
    result = profile_attachment_types.update_attributes(params.permit(:chinese_name, :english_name, :simple_chinese_name, :description))

    response_json result
  end

  def destroy
    authorize model
    profile_attachment_type = model.find(params[:id])
    profile_attachment_type.destroy

    response_json
  end

end