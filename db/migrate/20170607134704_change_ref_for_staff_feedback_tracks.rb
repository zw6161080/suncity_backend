class ChangeRefForStaffFeedbackTracks < ActiveRecord::Migration[5.0]
  def change
    rename_column :staff_feedback_tracks, :user_id, :tracker_id
  end
end
