class CreateApprovedJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :approved_jobs do |t|
      t.string :approved_job_name

      t.timestamps
    end
  end
end
