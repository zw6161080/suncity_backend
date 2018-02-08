class ChangeAppointmentTimeTypeInEntryAppointment < ActiveRecord::Migration[5.0]
  def change
    change_column :entry_appointments, :appointment_time, :string
  end
end
