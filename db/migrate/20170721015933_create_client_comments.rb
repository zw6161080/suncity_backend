class CreateClientComments < ActiveRecord::Migration[5.0]
  def change
    create_table :client_comments do |t|
      t.references :user, foreign_key: true, index: true

      t.string     :client_account
      t.string     :client_name
      t.datetime   :client_fill_in_date
      t.string     :client_phone
      t.datetime   :client_account_date
      t.string     :involving_staff
      t.datetime   :event_time_start
      t.datetime   :event_time_end
      t.string     :event_place

      t.references :last_tracker, foreign_key: { to_table: :users }, index: true
      t.datetime   :last_track_date
      t.string     :last_track_content

      t.timestamps
    end
  end
end
