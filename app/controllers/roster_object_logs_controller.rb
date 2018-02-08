class RosterObjectLogsController < ApplicationController

  def index
    roster_object = RosterObject.find_by(id: params[:roster_object_id])
    all_result = roster_object.roster_object_logs.order(created_at: :desc)
    final_result = all_result.as_json(
      include: {
        approver: {},
        roster_object: {include: :class_setting},
        class_setting: {},
        working_hours_transaction_record: {}
      },
      methods: []
    )
    response_json final_result
  end

end
