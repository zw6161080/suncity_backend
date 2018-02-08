class StaffFeedbackTracksController < ApplicationController

  # GET /staff_feedbacks/:staff_feedback_id/staff_feedback_tracks
  def index
    # authorize StaffFeedbackTrack
    response_json StaffFeedbackTrack
                      .detail_by_id(params[:staff_feedback_id])
                      .as_json(include: [:tracker])
  end

  # POST /staff_feedbacks/:staff_feedback_id/staff_feedback_tracks
  def create
    # authorize StaffFeedbackTrack
    staff_feedback_track = StaffFeedbackTrack.create(staff_feedback_track_params.as_json.merge(tracker_id: current_user.id))
    response_json staff_feedback_track
  end

  private
    # Only allow a trusted parameter "white list" through.
    def staff_feedback_track_params
      params.require(:staff_feedback_track).permit(*StaffFeedbackTrack.create_params)
    end
end
