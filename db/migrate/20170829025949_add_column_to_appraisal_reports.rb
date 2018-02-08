class AddColumnToAppraisalReports < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisal_reports, :appraisal_group, :string
  end
end
