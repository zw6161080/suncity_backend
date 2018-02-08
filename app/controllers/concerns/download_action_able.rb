module DownloadActionAble
  def download
    authorize model
    attachment = Attachment.find params[:id]
    headers['X-Accel-Redirect'] = Attachment.x_accel_url_with_hash(attachment.seaweed_hash)
    render body: nil
  end

  def model(special_table_name = nil)
    (special_table_name || controller_name).classify.constantize
  end
end