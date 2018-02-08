class CreateStaffFeedbackTracks < ActiveRecord::Migration[5.0]
  def change
    create_table :staff_feedback_tracks do |t|
      t.string :track_status, default: :untracked
      t.string :track_content
      t.references :staff_feedback, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
