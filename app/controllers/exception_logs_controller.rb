class ExceptionLogsController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: "develop", password: "dev@suncity4debug"
  before_action :set_log, only: [:show, :destroy]

  def index
    @logs = ExceptionLog.order('id desc').page(params[:page]).per(15)

    response_json @logs, meta: {
        total_count: @logs.total_count,
        current_page: @logs.current_page,
        total_pages: @logs.total_pages
    }
  end

  def show
    response_json @log
  end

  def destroy
    @log.destroy
   
    response_json
  end

  def all
    ExceptionLog.delete_all
    response_json notice: 'Logs was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_log
      @log = ExceptionLog.find(params[:id])
    end
end
