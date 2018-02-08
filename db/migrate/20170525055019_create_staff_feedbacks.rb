class CreateStaffFeedbacks < ActiveRecord::Migration[5.0]
  def change
    create_table :staff_feedbacks do |t|
      t.date :feedback_date, null: false, index: true
      t.string :feedback_title, null: false
      t.text :feedback_content, null: false
      t.references :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
