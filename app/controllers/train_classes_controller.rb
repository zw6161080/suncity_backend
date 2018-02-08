class TrainClassesController < ApplicationController

  # GET /train_classes 培训月历
  def index
    query = search_query_for_calendar.order('time_begin desc')
    data = query.map do |record|
      record.get_json_data
    end
    response_json data.as_json
  end

  # GET /train_classes/index_trains 培训课程
  def index_trains
    query = search_query_for_list
                .order('trains.created_at desc')
                .page
                .page(params.fetch(:page, 1))
                .per(10)
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: 'created_at',
        sort_direction: 'desc',
    }
    data = query.map do |record|
      new_record = record.as_json(methods: :train_template)
      if params[:by_whom] == 'by_department'
        entry_lists_user_ids = record.entry_lists.select(:user_id)
        final_lists_user_ids = record.final_lists.select(:user_id)
        new_record[:entry_lists_count] = User.where(id: entry_lists_user_ids).where(department_id: current_user.department_id).count rescue 0
        new_record[:final_lists_count] = User.where(id: final_lists_user_ids).where(department_id: current_user.department_id).count rescue 0
      end
      new_record
    end
    response_json data.as_json, meta: meta
  end

  private
    def search_query_for_calendar
      from  = Time.zone.parse(params[:year_month]).last_month.beginning_of_month
      to    = Time.zone.parse(params[:year_month]).next_month.end_of_month
      # by_department 部门的培训-培训月历
      # by_mine       我的培训-培训月历
      # by_hr         培训记录-培训月历
      case params[:by_whom]
        when 'by_department' then
          show_trains_in_department(current_user.department_id)
              .includes(:train, :title )
              .where(time_begin: from..to)
        when 'by_mine' then
          show_trains(current_user)
              .includes(:train, :title )
              .where(time_begin: from..to)
        when 'by_hr' then
          TrainClass
              .includes(:train, :title )
              .where(time_begin: from..to)
      end
    end



    def show_trains(user)
      train_ids = TrainingService.trains_in_status1(user) + user.trains.pluck(:id) + TrainingService.trains_in_status3(user)
      TrainClass.where(train_id: train_ids)
    end

    def show_trains_in_department(department_id)
      train_ids = []
      User.where(department_id: department_id).map do |user|
        ids = TrainingService.trains_in_status1(user) + user.trains.pluck(:id) + TrainingService.trains_in_status3(user)
        train_ids +=  ids
      end
      TrainClass.where(train_id: train_ids)
    end

    def search_query_for_list
      # by_department 部门的培训-培训课程
      # by_mine       我的培训-培训课程
      case params[:by_whom]
        when 'by_department' then
          query = Department.find(current_user.department_id).trains
                      .includes(:train_template_type)
        when 'by_mine' then
          query = User.find(current_user.id).trains
                      .includes(:train_template_type)
      end

      if params[:train_date]
        from = (Time.zone.parse(params[:train_date]['begin']).beginning_of_day rescue nil)
        to   = (Time.zone.parse(params[:train_date]['end']).end_of_day rescue nil)
        if from && to
          query = query.where('train_date_end >= :from AND train_date_begin <= :to', from: from, to: to)
        elsif from
          query = query.where('train_date_end >= :from', from: from)
        elsif to
          query = query.where('train_date_begin <= :to', to: to)
        end
      end

      if params[:registration_date]
        from = (Time.zone.parse(params[:registration_date]['begin']).beginning_of_day rescue nil)
        to   = (Time.zone.parse(params[:registration_date]['end']).end_of_day rescue nil)
        if from && to
          query = query.where('registration_date_end >= :from AND registration_date_begin <= :to', from: from, to: to)
        elsif from
          query = query.where('registration_date_end >= :from', from: from)
        elsif to
          query = query.where('registration_date_begin <= :to', to: to)
        end
      end

      if params[:registration_method]
        query = query.where(registration_method: params[:registration_method])
      end

      if params[:online_or_offline_training]
        query = query.where({online_or_offline_training: params[:online_or_offline_training]})
      end

      if params[:train_template_type_id]
        query = query.where({train_template_type_id: params[:train_template_type_id]})
      end

      if params[:training_credits]
        query = query.where({training_credits: params[:training_credits]})
      end

      query
    end

end
