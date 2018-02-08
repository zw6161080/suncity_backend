class CreateRosterModelStates < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_model_states do |t|
      t.integer :user_id
      t.integer :profile_id
      t.integer :roster_model_id

      t.boolean :is_effective
      t.date :effective_date
      t.date :start_date
      t.date :end_date

      t.integer :start_week_no
      t.integer :current_week_no

      t.integer :source_id

      t.timestamps
    end
  end
end
