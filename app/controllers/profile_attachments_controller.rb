class ProfileAttachmentsController < ApplicationController
  include MineCheckHelper
  before_action :set_profile
  before_action :set_user, only: [:index_by_user]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?
  def index

    authorize ProfileAttachment unless entry_from_mine?

    profile_attachments = ProfileAttachment.where(profile_id: @profile).as_json(include: [:creator, :attachment])

    response_json profile_attachments
  end

  def create
    authorize ProfileAttachment
    profileattachment = @profile.profile_attachments.create(creator_id: current_user.id)
    pa = profileattachment.update(params.permit(:file_name, :profile_attachment_type_id, :description, :attachment_id))
    profileattachment.update_profile_filled_attachment_types if pa == true
    response_json
  end

  def update
    authorize ProfileAttachment
    profile_attachment = @profile.profile_attachments.find(params[:id])
    result = profile_attachment.update_attributes(params.permit(:file_name, :profile_attachment_type_id, :description, :attachment_id))

    response_json result
  end

  def destroy
    authorize ProfileAttachment
    profile_attachment = @profile.profile_attachments.find(params[:id])
    profile_attachment.destroy

    response_json
  end


  def download
    profile_attach = @profile.profile_attachments.find(params[:id])
    headers['X-Accel-Redirect'] = profile_attach.attachment.x_accel_url
    render body: nil
  end


  def preview
    attachment = @profile.profile_attachments.find(params[:id]).attachment

    if 'convert_success' == attachment.preview_state.to_s
      headers['X-Accel-Redirect'] = Attachment.x_accel_url_with_hash(attachment.preview_hash)
      render body: nil
    else
      raise LogicError, {id: 422, message: attachment.preview_state.to_s.titleize}.to_json
    end
  end
  
  private
  def set_user
    @user = @profile.user

  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

end
