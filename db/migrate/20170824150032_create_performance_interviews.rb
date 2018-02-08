class CreatePerformanceInterviews < ActiveRecord::Migration[5.0]
  def change
    create_table :performance_interviews do |t|
      t.references :appraisal, index: true, foreign_key: true
      t.references :appraisal_participator, index: true, foreign_key: true
      t.boolean    :performance_status
      t.datetime  :interview_date
      t.datetime  :interview_time_begin
      t.datetime  :interview_time_end
      t.datetime  :operator_at
      t.timestamps
    end

    add_reference :performance_interviews, :performance_moderator, index: true
    add_foreign_key :performance_interviews, :users, column: :performance_moderator_id

    add_reference :performance_interviews, :operator, index: true
    add_foreign_key :performance_interviews, :users, column: :operator_id
  end
end
