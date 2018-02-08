class AttendancesController < ApplicationController
  def index
    region = params[:region]

    attendances = Attendance.includes([:location, :department])
                    .where(region: region)
                    .order(created_at: :desc)
                    .by_year(params[:year])
                    .by_month(params[:month])
                    .by_location_id(params[:location_id])
                    .by_department_id(params[:department_id])
                    .page(params[:page]).per(10)

    response_json attendances, pagination: true do |attendances_rst|
      attendances_rst.as_json(
        include: [:location, :department],
        methods: [:department_employees_count,
                  :roster_items_count,
                  :office_leave_count,
                  :punching_card_records,
                  :unusual_punching_card_records]
      )
    end
  end

  def show
    attendance = Attendance.find(params[:id])
    response_json attendance.as_json(include: [:location, :department],
                                     methods: [:department_employees_count,
                                               :punching_card_records,
                                               :unusual_punching_card_records])
  end

  def get_period
    region = params[:region]
    rst = Attendance.where(region: region)
            .by_location_id(params[:location_id])
            .by_department_id(params[:department_id])
            .select(:year, :month).to_a.map { |a| "#{a.year}_#{a.month}" }
            .uniq
            .sort do |p1, p2|
      p1 >= p2 ? -1 : 1
    end

    response_json rst.as_json
  end

end
