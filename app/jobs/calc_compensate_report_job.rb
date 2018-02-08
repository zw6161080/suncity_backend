class CalcCompensateReportJob < ApplicationJob
  queue_as :attend_report

  def perform(year, month)
    CompensateReport.generate_reports(year, month)
  end
end
