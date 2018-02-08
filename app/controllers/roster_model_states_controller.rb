class RosterModelStatesController < ApplicationController
  def index
    rmss = RosterModelState.where(user_id: params[:user_id], source_id: nil).order("start_date desc")
    # format_rmss = format_result(rmss.as_json)
    # respond_json format_rmss
    final_result = rmss.as_json(include: [:roster_model])
    response_json final_result
  end

  def create
    ActiveRecord::Base.transaction do
      rms = RosterModelState.create(roster_model_state_params)
      start_date = params[:start_date].in_time_zone.to_date
      time_now = Time.zone.now.to_date
      rms.current_week_no = nil

      rms.save!

      next_rms = RosterModelState.where(user_id: rms.user_id, source_id: nil).where("start_date > ?", start_date).order("start_date desc")&.last
      now_end_date = rms&.end_date&.to_date
      next_start = next_rms&.start_date&.to_date

      end_date = now_end_date ? now_end_date : (next_start ? next_start - 1.day : nil)

      if start_date <= time_now
        if (end_date == nil || (end_date && end_date >= time_now))

          start_week_no = params[:start_week_no].to_i
          roster_m = RosterModel.find_by(id: rms.roster_model_id)
          weeks_count = roster_m.weeks_count if roster_m

          if start_week_no && weeks_count
            w_count = (start_date .. time_now).reduce(0) do |sum, d|
              sum = (d.wday == 1 && d != start_date) ? sum + 1 : sum
              sum
            end

            current_week_no_should = (start_week_no + w_count) % weeks_count
            rms.current_week_no = current_week_no_should == 0 ? weeks_count : current_week_no_should
            rms.save!
          end

        elsif end_date && end_date < time_now
          start_week_no = params[:start_week_no].to_i
          roster_m = RosterModel.find_by(id: rms.roster_model_id)
          weeks_count = roster_m.weeks_count if roster_m

          if start_week_no && weeks_count
            w_count = (start_date .. end_date).reduce(0) do |sum, d|
              sum = (d.wday == 1 && d != start_date) ? sum + 1 : sum
              sum
            end

            current_week_no_should = (start_week_no + w_count) % weeks_count
            rms.current_week_no = current_week_no_should == 0 ? weeks_count : current_week_no_should
            rms.save!
          end
        end

        # current = rms.histories.order(created_at: :desc).first
        # if current
        #   # current.end_date = time_now
        #   current.end_date = rms.start_date
        #   current.is_current = false
        #   current.save!
        # end
      end

      rms.save!
      response_json :ok
    end
  end

  def update
    authorize RosterModelState
    ActiveRecord::Base.transaction do
      rms = RosterModelState.find(params[:id])
      rms.update(roster_model_state_params)
      rms.current_week_no = nil
      rms.save!

      start_date = rms.start_date.in_time_zone.to_date
      time_now = Time.zone.now.to_date

      next_rms = RosterModelState.where(user_id: rms.user_id, source_id: nil).where("start_date > ?", start_date).order("start_date desc")&.last
      now_end_date = rms&.end_date&.to_date
      next_start = next_rms&.start_date&.to_date

      end_date = now_end_date ? now_end_date : (next_start ? next_start - 1.day : nil)

      if start_date <= time_now
        if (end_date == nil || (end_date && end_date >= time_now))

          start_week_no = params[:start_week_no].to_i
          roster_m = RosterModel.find_by(id: rms.roster_model_id)
          weeks_count = roster_m.weeks_count if roster_m

          if start_week_no && weeks_count
            w_count = (start_date .. time_now).reduce(0) do |sum, d|
              sum = (d.wday == 1 && d != start_date) ? sum + 1 : sum
              sum
            end

            current_week_no_should = (start_week_no + w_count) % weeks_count
            rms.current_week_no = current_week_no_should == 0 ? weeks_count : current_week_no_should
            rms.save!
          end

        elsif end_date && end_date < time_now
          start_week_no = params[:start_week_no].to_i
          roster_m = RosterModel.find_by(id: rms.roster_model_id)
          weeks_count = roster_m.weeks_count if roster_m

          if start_week_no && weeks_count
            w_count = (start_date .. end_date).reduce(0) do |sum, d|
              sum = (d.wday == 1 && d != start_date) ? sum + 1 : sum
              sum
            end

            current_week_no_should = (start_week_no + w_count) % weeks_count
            rms.current_week_no = current_week_no_should == 0 ? weeks_count : current_week_no_should
            rms.save!
          end
        end
      end

      rms.save!
      response_json :ok
    end
  end

  def destroy
    rms = RosterModelState.find_by(id: params[:id])
    rms.destroy
    response_json :ok
  end

  def be_able_apply
    result = {}
    start_date = params[:start_date].in_time_zone.to_date rescue nil
    end_date = params[:end_date].in_time_zone.to_date rescue nil

    ans = false

    if start_date
      tmp_rmss = RosterModelState.where(user_id: params[:user_id], source_id: nil)
      rmss = params[:edit_record_id] ? tmp_rmss.where.not(id: params[:edit_record_id]) : tmp_rmss
      start_end_dates = rmss.pluck(:start_date, :end_date)
      params_date_pair = [start_date, end_date]
      start_dates = (start_end_dates + [params_date_pair]).map { |date_pair| date_pair.first }
      if start_dates.compact.uniq.length == start_dates.length
        full_dates = (start_end_dates + [params_date_pair]).sort_by { |date_pair| date_pair.first }.flatten.compact.uniq
        sorted_full_dates = full_dates.sort
        ans = full_dates == sorted_full_dates
      end

      # selected_date = sorted_start_end_date.select { |date_arr| params[:start_date] }
      # sorted_start_end_date.map { |date_arr| date_arr.last == nil ? date_arr }
    end

    result[:be_able_apply] = ans
    response_json result.as_json
  end

  def roster_model_weeks_count
    roster_model = RosterModel.find_by(id: params[:roster_model_id])
    weeks_count = roster_model ? roster_model.weeks_count : 0
    response_json weeks_count
  end

  def histories
    params[:page] ||= 1
    meta = {}
    all_result = RosterModelState
                   .where(user_id: params[:user_id])
                   .where.not(source_id: nil)
                   .order(created_at: :desc)

    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def user_roster_models_info
    start_date = params[:start_date]
    end_date = params[:end_date]

    users = User.where(location_id: params[:location_id], department_id: params[:department_id])

    result = users.map do |u|
      roster_model_states = u.roster_model_states.where(source_id: nil)
      rms = roster_model_states.where("start_date > ? AND start_date <= ?", start_date, end_date).order(start_date: :asc)
      any_one = roster_model_states.where("start_date <= ?", start_date).order(start_date: :asc).last

      all_rms = ([any_one] + rms).compact.map do |r|
        # r.as_json(include: [:roster_model])
        roster_model_weeks_table = []
        if r && r.roster_model_id
          rm = RosterModel.find_by(id: r.roster_model_id)
          if rm
            weeks = rm.roster_model_weeks
            roster_model_weeks_table = weeks.map do |w|
              w.as_json.merge(
                {
                  mon: ClassSetting.find_by(id: w.mon_class_setting_id).as_json,
                  tue: ClassSetting.find_by(id: w.tue_class_setting_id).as_json,
                  wed: ClassSetting.find_by(id: w.wed_class_setting_id).as_json,
                  thu: ClassSetting.find_by(id: w.thu_class_setting_id).as_json,
                  fri: ClassSetting.find_by(id: w.fri_class_setting_id).as_json,
                  sat: ClassSetting.find_by(id: w.sat_class_setting_id).as_json,
                  sun: ClassSetting.find_by(id: w.sun_class_setting_id).as_json
                }
              )
            end
          end
          ro_with_weeks = rm.as_json().merge(
            roster_model_weeks: roster_model_weeks_table
          )
          r.as_json().merge(
            roster_model: ro_with_weeks
          )
        else
          r.as_json
        end
      end

      {
        user: u,
        shift_status: u.shift_status,
        roster_model_states: all_rms
      }
    end
    response_json result.as_json
  end

  def update_is_current_for_all
    RosterModelState.where(source_id: nil).each do |rms|
      current = rms.histories.order(created_at: :desc).first
      if current
        current.is_current = true
        current.save
      end
    end
    response_json :ok
  end

  private

  def roster_model_state_params
    params.require(:roster_model_state).permit(
      :user_id,
      :roster_model_id,
      :start_date,
      :end_date,
      :start_week_no,
    )
  end

  def format_result(json)
    json.map do |hash|
      roster_model = hash['roster_model_id'] ? RosterModel.find(hash['roster_model_id']) : nil
      hash['roster_model'] = roster_model ?
      {
        id: roster_model['id'],
        chinese_name: roster_model['chinese_name'],
      } : nil

      hash
    end
  end
end
