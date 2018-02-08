class PunchLogsController < ApplicationController

  def index
    user = User.find(params[:user_id])
    date = Date.parse(params[:date])
    logs = RosterEventLogV2.of_user_date(user, date)

    response_json logs.as_json(only: [], methods: [:convertDatetime])
  end
end
