class CreateSpecialScheduleRemarks < ActiveRecord::Migration[5.0]
  def change
    create_table :special_schedule_remarks do |t|
      t.references :user, foreign_key: true, index: true
      t.datetime :date_begin
      t.datetime :date_end
      t.text :content
      t.timestamps
    end
  end
end
