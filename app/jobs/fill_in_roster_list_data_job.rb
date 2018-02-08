class FillInRosterListDataJob < ApplicationJob
  queue_as :default
  attr_accessor :item_id

  before_perform do |job|
    roster_list = job.arguments.first
    if roster_list
      roster_list.calc_state = 'calculating'
      roster_list.save
    end
  end

  after_perform do |job|
    roster_list = job.arguments.first
    if roster_list
      roster_list.calc_state = 'calculated'
      roster_list.save
    end
  end

  rescue_from(StandardError) do |exception|
    roster_list = RosterList.find_by(id: item_id)
    if roster_list
      roster_list.calc_state = 'calculated'
      roster_list.save
    end
    Rails.logger.error "backtrace: #{exception} "
    Rails.logger.error "backtrace: #{exception.backtrace} "
    raise exception
  end

  def perform(roster_list)
    # Do something later
    self.item_id = roster_list.id
    roster_list.fill_in_data
  end
end
