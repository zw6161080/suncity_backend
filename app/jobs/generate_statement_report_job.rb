class GenerateStatementReportJob < ApplicationJob
  include GenerateXlsxHelper
  attr_accessor :item_id
  queue_as :statement_report

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    MyAttachment.where(id: item_id).destroy_all if item_id
    Rails.logger.info "exception: #{exception} "
    Rails.logger.info "backtrace: #{exception.backtrace} "
    raise exception
  end

  def perform(**args)
    # Do something later
    self.item_id = args[:my_attachment].id
    generate_statement_xlsx(args.merge({query: args[:query_model].to_s.classify.constantize.where(id: args[:query_ids])}))
  end
end
