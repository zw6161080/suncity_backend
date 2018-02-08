class CreateAttendQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_questionnaires do |t|
      t.belongs_to :questionnaire
      t.integer :attachable_id
      t.string  :attachable_type
    end
    add_index :attend_questionnaires, [:attachable_type, :attachable_id], name: 'a_q'
  end
end
