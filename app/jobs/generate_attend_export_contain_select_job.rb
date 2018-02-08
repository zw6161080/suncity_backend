class GenerateAttendExportContainSelectJob < ApplicationJob
  queue_as :default
  attr_accessor :item_id
  rescue_from(StandardError) do |exception|
    # Do something with the exception
    MyAttachment.where(id: item_id).destroy_all if item_id
    Rails.logger.info "exception: #{exception} "
    Rails.logger.info "backtrace: #{exception.backtrace} "
    raise exception
  end

  def perform(params, my_attachment)
    # Do something later
    self.item_id = my_attachment.id
    AttendsController.select_and_generate_report(params, my_attachment)
  end
end
