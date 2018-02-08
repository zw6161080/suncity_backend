class AddCancelReasonToInterviews < ActiveRecord::Migration[5.0]
  def change
    add_column :interviews, :cancel_reason, :text
  end
end
