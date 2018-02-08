class AppraisalAttachmentsController < ApplicationController
  before_action :set_appraisal_attachment, only: [:update, :destroy]
  before_action :set_appraisal_basic_setting, only: [:create, :update, :destroy]

  # GET /appraisal_basic_setting/attachments
  def index
    appraisal_attachments = AppraisalAttachment.all
    render json: appraisal_attachments
  end

  # POST /appraisal_attachments
  def create
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless appraisal_attachment_params
    appraisal_attachments = @appraisal_basic_setting.appraisal_attachments.create(
        appraisal_attachment_params.as_json.merge(creator_id: current_user.id))
    render json: appraisal_attachments
  end

  # PATCH/PUT /appraisal_basic_setting/attachment/:id
  def update
    attach = @appraisal_basic_setting.appraisal_attachments.find(params[:id])
    raise LogicError, {id: 422, message: '相关文件不存在'}.to_json unless attach
    result = attach.update_attributes(params.permit(:attachment_id, :file_name, :file_type, :comment))

    render json: result
  end

  # DELETE /appraisal_basic_setting/attachment/:id
  def destroy
    render json: @appraisal_basic_setting.appraisal_attachments.find(params[:id]).destroy

  end

  def download
    appraisal_attachment = @appraisal_basic_setting.appraisal_attachments.find(params[:id])
    raise LogicError, {id: 422, message: '相关文件不存在'}.to_json unless appraisal_attachment
    headers['X-Accel-Redirect'] = appraisal_attachment.attachment.x_accel_url
    render body: nil
  end

  def preview
    appraisal_attachment = @appraisal_basic_setting.appraisal_attachments.find(params[:id]).attachment
    raise LogicError, {id: 422, message: '相关文件不存在'}.to_json unless appraisal_attachment
    if 'convert_success' == appraisal_attachment.preview_state.to_s
      headers['X-Accel-Redirect'] = Attachment.x_accel_url_with_hash(appraisal_attachment.preview_hash)
      render body: nil
    else
      raise LogicError, {id: 422, message: appraisal_attachment.preview_state.to_s.titleize}.to_json
    end
  end

  private
    def set_appraisal_attachment
      @appraisal_attachment = AppraisalAttachment.find(params[:id])
    end

    def appraisal_attachment_params
      params.permit(*AppraisalAttachment.create_params)
    end

    def set_appraisal_basic_setting
      @appraisal_basic_setting = AppraisalBasicSetting.all.first
    end
end
