class AddColumnsToAppraisals < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisals, :release_reports, :boolean
    add_column :appraisals, :release_interviews, :boolean
  end
end
