class AddColumnsToStaffFeedback < ActiveRecord::Migration[5.0]
  def change
    add_reference :staff_feedbacks, :feedback_tracker, foreign_key: { to_table: :users }
    add_column :staff_feedbacks, :feedback_track_date, :datetime
    add_column :staff_feedbacks, :feedback_track_content, :string
  end
end
