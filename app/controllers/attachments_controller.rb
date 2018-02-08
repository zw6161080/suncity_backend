# coding: utf-8
class AttachmentsController < ApplicationController
  include DownloadActionAble
  def create
    attachment = Attachment.new
    attachment.file = params[:file]
    attachment.save

    response_json attachment.as_json(only: ['id', 'file_name'])
  end

  def upload_avatar
    attachment = Attachment.new
    attachment.file = params[:file]
    attachment.save

    data = { path: "/avatar/#{attachment.seaweed_hash}" }

    response_json data
  end

  def preview
    attachment = Attachment.find params[:id]
    if attachment.convert_success?
      headers['X-Accel-Redirect'] = Attachment.x_accel_url_with_hash(attachment.preview_hash)
      render body: nil
    else
      message = '文件預覽 未知錯誤'

      if attachment.converting?
        message = '文件還在轉換中 請稍候再來看'
      end

      if attachment.unsupport_file_type?
        message =  '當前文件類型不支持預覽'
      end

      if attachment.convert_fail?
        message = '文件預覽轉換失敗'
      end

      raise LogicError, {message: message}.to_json
    end
  end

  def avatar
    headers['X-Accel-Redirect'] = Attachment.x_accel_url_with_hash(params[:seaweed_hash])
    render body: nil
  end

end
