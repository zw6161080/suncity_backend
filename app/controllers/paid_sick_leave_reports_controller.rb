class PaidSickLeaveReportsController < ApplicationController
  def create
    ActiveRecord::Base.transaction do
      psl = PaidSickLeaveReport.create(paid_sick_leave_report_params)
      User.all.each do |u|
        start_date = Time.zone.local(params[:year].to_i, 1, 1).to_date.beginning_of_year
        end_date = Time.zone.local(params[:year].to_i, 1, 1).to_date.end_of_year
        records = HolidayRecord.where(user_id: u.id,
                                      source_id: nil,
                                      start_date: start_date..end_date,
                                      holiday_type: 'paid_sick_leave',
                                      is_deleted: [false, nil])

        counts = records.inject(0) do |sum, r|
          sum += r.days_count.to_i
        end

        # entry_date_str = u.profile.data['position_information']['field_values']['date_of_employment']
        entry_date_str = u.profile.data['position_information']['field_values']['date_of_employment']
        entry_date = entry_date_str&.in_time_zone&.to_date

        on_duty_days = 0
        if entry_date
          time_now = Time.zone.now.to_date
          on_duty_days = entry_date.year == params[:year].to_i ? (time_now - entry_date).to_i + 1 : (end_date - entry_date).to_i + 1
        end

        o_counts = HolidayRecord.calc_paid_bonus_leave_count(u, params[:year].to_i)

        PaidSickLeaveReportItem.create(
          paid_sick_leave_report_id: psl.id,
          user_id: u.id,
          department_id: u.department_id,
          year: params[:year].to_i,
          valid_period: params[:valid_period],
          entry_date: entry_date_str,
          paid_sick_leave_counts: counts > 0 ? counts : 0,
          on_duty_days: on_duty_days > 0 ? on_duty_days : 0,
          obtain_counts: o_counts > 0 ? o_counts : 0,
        )
      end
      response_json :ok
    end
  end

  def release
    report = PaidSickLeaveReport.where(year: params[:year].to_i).first
    report.update(is_release: true) if report
    items = PaidSickLeaveReportItem.where(year: params[:year].to_i)
    items.each do |item|
      item.is_release = true
      item.save!
    end

    response_json :ok
  end

  def remove
    ActiveRecord::Base.transaction do
      report = PaidSickLeaveReport.where(year: params[:year].to_i).first
      report.destroy if report
      response_json :ok
    end
  end

  private

  def paid_sick_leave_report_params
    params.require(:paid_sick_leave_report).permit(
      :year,
      :valid_period
    )
  end
end
