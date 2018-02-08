class ApplicantAttachmentsController < ApplicationController
  before_action :set_applicant_profile

  def index
    applicant_attachments = @applicant_profile.applicant_attachments.as_json(include: [:creator, :attachment])

    response_json applicant_attachments
  end

  def create
    applicant_attachment = @applicant_profile.applicant_attachments.create(params.permit(:file_name, :applicant_attachment_type_id, :description, :attachment_id).merge(:creator_id => current_user_id))

    response_json
  end

  def update
    applicant_attachment = @applicant_profile.applicant_attachments.find(params[:id])
    result = applicant_attachment.update_attributes(params.permit(:file_name, :applicant_attachment_type_id, :description, :attachment_id))

    response_json result
  end

  def destroy
    applicant_attachment = @applicant_profile.applicant_attachments.find(params[:id])
    applicant_attachment.destroy

    response_json
  end


  def download
    applicant_attach = @applicant_profile.applicant_attachments.find(params[:id])
  
    headers['X-Accel-Redirect'] = applicant_attach.attachment.x_accel_url
    render body: nil
  end  

  def preview
    attachment = @applicant_profile.applicant_attachments.find(params[:id]).attachment

    if 'convert_success' == attachment.preview_state.to_s
      headers['X-Accel-Redirect'] = Attachment.x_accel_url_with_hash(attachment.preview_hash)
      render body: nil
    else
      raise LogicError, {id: 422, message: attachment.preview_state.to_s.titleize}.to_json
    end
  end

  private

  def set_applicant_profile
    @applicant_profile = ApplicantProfile.find(params[:applicant_profile_id])
  end

end
