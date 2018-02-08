class UpdateAttendMonthApprovalJob < ApplicationJob
  queue_as :attend_report
  attr_accessor :item_id

  before_perform do |job|
    approval = job.arguments.first
    if approval
      approval.calc_state = 'calculating'
      approval.save
    end
  end

  after_perform do |job|
    approval = job.arguments.first
    if approval
      approval.calc_state = 'calculated'
      approval.save
    end
  end

  rescue_from(StandardError) do |exception|
    approval = AttendMonthApproval.find_by(id: item_id)
    if approval
      approval.calc_state = 'calculated'
      approval.save
    end
    Rails.logger.error "backtrace: #{exception} "
    Rails.logger.error "backtrace: #{exception.backtrace} "
    raise exception
  end

  def perform(approval)
    # Do something later
    self.item_id = approval.id
    approval.set_data
  end
end
