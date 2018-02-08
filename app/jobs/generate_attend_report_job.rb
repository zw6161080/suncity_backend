class GenerateAttendReportJob < ApplicationJob
  include GenerateXlsxHelper
  attr_accessor :item_id
  queue_as :default

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    MyAttachment.where(id: item_id).destroy_all if item_id
    Rails.logger.info "backtrace: #{exception} "
    Rails.logger.info "backtrace: #{exception.backtrace} "
    raise exception
  end

  def perform(**args)
    # Do something later
    self.item_id = args[:my_attachment].id
    generate_attend_report(args.merge(table_fields: args[:controller_name].classify.constantize.send(args[:table_fields_methods], *args[:table_fields_args])))
  end
end
