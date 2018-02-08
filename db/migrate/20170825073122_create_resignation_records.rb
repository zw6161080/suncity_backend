class CreateResignationRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :resignation_records do |t|
      t.integer :user_id
      t.string :status
      t.string :time_arrive
      t.datetime :resigned_date
      t.string :resigned_reason
      t.string :reason_for_resignation
      t.string :employment_status
      t.integer :department_id
      t.integer :position_id
      t.string :comment
      t.timestamps
    end
  end
end
