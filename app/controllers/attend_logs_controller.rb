class AttendLogsController < ApplicationController
  before_action :set_attend, only: [:index, :raw_index, :index_by_department, :index_by_current_user]

  def index_by_department
    authorize AttendLog
    raw_index
  end

  def index_by_current_user
    raw_index
  end

  def raw_index
    params[:page] ||= 1
    meta = {}
    all_result = @attend.attend_logs.order(created_at: :desc)

    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [], methods: []))
    response_json final_result, meta: meta
  end

  def index
    authorize AttendLog
    raw_index
  end

  private

  def set_attend
    @attend = Attend.find(params[:attend_id])
  end

  def format_result(json)
    json.map do |hash|
      logger = hash['logger_id'] ? User.find(hash['logger_id']) : nil
      hash['logger'] = logger ?
      {
        id: logger['id'],
        chinese_name: logger['chinese_name'],
        english_name: logger['english_name'],
        simple_chinese_name: logger['chinese_name'],
      } : nil

      hash
    end
  end
end
