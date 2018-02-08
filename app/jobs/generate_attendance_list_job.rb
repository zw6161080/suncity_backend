class GenerateAttendanceListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    current = Time.zone.now.to_datetime
    Attendance.generate_attendance_list(current.year, current.month)
    # attendances = Attendance.where(year: 2017, month: 3)

    # attendances.each do |attendance|
    #   attendance.start_attendancing
    # end
  end
end
