class RemoveReferencesFromReservedHolidayParticipators < ActiveRecord::Migration[5.0]
  def change
    remove_reference :reserved_holiday_participators, :holiday_record
  end
end
