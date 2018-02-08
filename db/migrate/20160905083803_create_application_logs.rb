class CreateApplicationLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :application_logs do |t|
      t.belongs_to :applicant_position
      t.belongs_to :user
      t.string :behavior
      t.jsonb :info

      t.timestamps
    end
  end
end
