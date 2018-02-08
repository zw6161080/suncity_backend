class AccountingMonthSalaryReportJob < ApplicationJob
  attr_accessor :item_id
  queue_as :default

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    msr = MonthSalaryReport.where(id: item_id).first
    if msr
      SalaryValue.where(year_month: msr.year_month, salary_type: msr.salary_type).destroy_all
      msr.destroy
    end
    Rails.logger.info "backtrace: #{exception.backtrace} "
    raise exception
  end

  def perform(month_salary_report)
    return unless month_salary_report.status.to_sym == :not_calculating
    self.item_id = month_salary_report.id
    month_salary_report.calculate
  end
end
