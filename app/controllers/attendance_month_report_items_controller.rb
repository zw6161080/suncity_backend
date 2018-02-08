class AttendanceMonthReportItemsController < ApplicationController
  include StatementBaseActions

  def year_month_options
    render json: AttendanceMonthReportItem.year_month_options, status: :ok
  end
end
