class CalcAttendAnnualReportJob < ApplicationJob
  queue_as :attend_report

  def perform(year)
    AttendAnnualReport.generate_reports(year)
  end
end
