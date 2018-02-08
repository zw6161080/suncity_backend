class ChangeAppointmentTimeTypeInDimissionAppointment < ActiveRecord::Migration[5.0]
  def change
    change_column :dimission_appointments, :appointment_time, :string
  end
end
