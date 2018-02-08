class MyAttachmentsController < ApplicationController
  before_action :set_my_attachment, only: [:download, :destroy]
  before_action :set_user, only: [:head_index, :all_index]

  def head_index
    render json: @user.head_index
  end

  def all_index
    Rails.cache.write("more_record_count_#{current_user.id}", params[:more_record_count] || 1)
    Rails.cache.write("search_key_#{current_user.id}", params[:search_key])
    res = @user.all_index(params.permit(:query_key, :more_record_count))
    render json: res[:query], root: 'data', meta: res[:meta]
  end

  # GET /my_attachments/1/download
  def download
    headers['X-Accel-Redirect'] = @my_attachment.attachment&.x_accel_url
    render body: nil
  end

  # DELETE /my_attachments/1
  def destroy
    render json: @my_attachment.destroy
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_my_attachment
      @my_attachment = MyAttachment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def my_attachment_params
      params.fetch(:my_attachment, {})
    end
end
