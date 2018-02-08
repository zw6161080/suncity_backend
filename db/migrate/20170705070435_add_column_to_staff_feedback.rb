class AddColumnToStaffFeedback < ActiveRecord::Migration[5.0]
  def change
    add_column :staff_feedbacks, :feedback_track_status, :string
  end
end
