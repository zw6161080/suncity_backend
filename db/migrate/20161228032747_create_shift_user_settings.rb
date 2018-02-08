class CreateShiftUserSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :shift_user_settings do |t|
      t.belongs_to :user
      t.belongs_to :roster

      t.jsonb :shift_interval
      t.jsonb :shift_special
      t.jsonb :rest_interval
      t.jsonb :rest_special

      t.timestamps
    end
  end
end
