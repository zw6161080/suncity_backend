class CalcAttendMonthReportJob < ApplicationJob
  queue_as :attend_report

  def perform(year, month)
    AttendMonthlyReport.generate_reports(year, month)
  end
end
