class AccountAnnualAwardItemsJob < ApplicationJob
  queue_as :default

  attr_accessor :item_id

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    AnnualAwardReport.where(id: item_id).first&.update(status: :fail) if item_id
    Rails.logger.info "exception: #{exception} "
    Rails.logger.info "backtrace: #{exception.backtrace} "
    raise exception
  end

  def perform(annual_award_report)
    return unless annual_award_report.status  == 'calculating'
    self.item_id = annual_award_report.id
    annual_award_report.generate_item
    annual_award_report.update(status: :not_granted)
  end

end