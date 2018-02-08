class RefreshAttendAnnualReportJob < ApplicationJob
  queue_as :attend_report
  attr_accessor :item_id

  before_perform do |job|
    report = job.arguments.first
    report.status = 'calculating'
    report.save
  end

  after_perform do |job|
    report = job.arguments.first
    report.status = 'calculated'
    report.save
  end

  rescue_from(StandardError) do |exception|
    report = AttendAnnualReport.find_by(id: item_id)

    if report
      report.status = 'calculated'
      report.save
    end
    Rails.logger.error "backtrace: #{exception} "
    Rails.logger.error "backtrace: #{exception.backtrace} "

    raise exception
  end

  def perform(report)
    self.item_id = report.id
    report.refresh_data(report.year)
  end
end
