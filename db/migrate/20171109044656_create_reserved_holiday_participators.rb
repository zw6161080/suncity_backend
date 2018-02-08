class CreateReservedHolidayParticipators < ActiveRecord::Migration[5.0]
  def change
    create_table :reserved_holiday_participators do |t|
      t.references :reserved_holiday_setting, foreign_key: true, index: { name: 'index_participators_on_reserved_holiday_setting_id'}
      t.references :user, foreign_key: true, index: true
      t.integer :owned_days_count
      t.integer :taken_days_count
      t.references :holiday_record, foreign_key: true, index: true
      t.timestamps
    end
  end
end
