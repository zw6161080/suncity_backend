class MonthSalaryReportGeneratingJobJob < ApplicationJob
  include GenerateXlsxHelper
  attr_accessor :item_id
  queue_as :default

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    MyAttachment.where(id: item_id).destroy_all
    Rails.logger.info "exception: #{exception} "
    Rails.logger.info "backtrace: #{exception.backtrace} "
    raise exception
  end


  def perform(year_month_users_ids, salary_values_ids, original_column_order, msa, report_type)
    # Do something later
    self.item_id = msa.id
    if [:index, :show].include? report_type.to_sym
      msa = generate_month_salary_report_table(year_month_users_ids, salary_values_ids, original_column_order, msa)
    else
      msa = generate_month_salary_report_by_left_table(year_month_users_ids, salary_values_ids, original_column_order, msa)
    end
    msa
  end
end
