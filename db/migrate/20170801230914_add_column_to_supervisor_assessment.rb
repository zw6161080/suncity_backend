class AddColumnToSupervisorAssessment < ActiveRecord::Migration[5.0]
  def change
    add_column :supervisor_assessments, :train_id, :integer
  end
end
