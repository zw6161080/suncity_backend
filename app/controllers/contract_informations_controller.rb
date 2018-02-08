class ContractInformationsController < ApplicationController
  include MineCheckHelper
  before_action :set_profile
  before_action :set_user, only: [:index_by_user]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?
  def index
    authorize ContractInformation unless entry_from_mine?
    profile_attachments = ContractInformation.where(profile_id: @profile).as_json(include: [:creator, :attachment])

    response_json profile_attachments
  end

  def create
    authorize ContractInformation
    @profile.contract_informations.create(creator_id: current_user.id).update(params.permit(:file_name, :contract_information_type_id, :description, :attachment_id))
    response_json
  end

  def update
    authorize ContractInformation
    profile_attachment = @profile.contract_informations.find(params[:id])
    result = profile_attachment.update_attributes(params.permit(:file_name, :contract_information_type_id, :description, :attachment_id))

    response_json result
  end

  def destroy
    authorize ContractInformation
    profile_attachment = @profile.contract_informations.find(params[:id])
    profile_attachment.destroy

    response_json
  end


  def download
    authorize ContractInformation
    profile_attach = @profile.contract_informations.find(params[:id])
    headers['X-Accel-Redirect'] = profile_attach.attachment.x_accel_url
    render body: nil
  end


  def preview
    authorize ContractInformation
    attachment = @profile.contract_informations.find(params[:id]).attachment

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
