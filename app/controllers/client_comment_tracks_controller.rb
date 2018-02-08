class ClientCommentTracksController < ApplicationController

  before_action :set_client_comment_track, only: [:show, :update, :destroy]

  # GET /client_comment_tracks/1
  def show
    authorize ClientCommentTrack
    render json: @client_comment_track.as_json(include: :user)
  end

  # POST /client_comments/client_comment_id/client_comment_tracks
  def create
    # authorize ClientCommentTrack
    client_comment_track = ClientCommentTrack.create(client_comment_track_params.as_json.merge(
        user_id: current_user.id,
        track_date: Time.zone.now,
        client_comment_id: params[:client_comment_id]
    ))
    response_json client_comment_track
  end

  # PATCH/PUT /client_comments/client_comment_id/client_comment_tracks/1
  def update
    # authorize ClientCommentTrack
    if @client_comment_track.update(client_comment_track_params.permit(:content))
      render json: @client_comment_track
    else
      render json: @client_comment_track.errors, status: :unprocessable_entity
    end
  end

  # DELETE /client_comment_tracks/1
  def destroy
    authorize ClientCommentTrack
    @client_comment_track.destroy
    response_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client_comment_track
      @client_comment_track = ClientCommentTrack.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def client_comment_track_params
      params.require(:client_comment_track).permit(*ClientCommentTrack.create_params)
    end
end
