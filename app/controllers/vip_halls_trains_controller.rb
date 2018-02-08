class VipHallsTrainsController < ApplicationController

  include SortParamsHelper

  # GET /vip_halls_trains
  def index
    authorize VipHallsTrain
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
                .order(sort_column => sort_direction)
                .page
                .page(params.fetch(:page, 1))
                .per(10)
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s,
    }
    data = query.map do |record|
      record.get_json_data
    end
    response_json data.as_json, meta: meta
  end

  # POST /vip_halls_trains
  def create
    authorize VipHallsTrain
    adjusted_train_month = Time.zone.parse(vip_halls_train_params[:train_month])
    new_ids = []
    params['vip_halls_train']['location_ids'].each do |location_id|
      vip_halls_train = VipHallsTrain.create({
                                                 location_id: location_id.to_i,
                                                 train_month: adjusted_train_month,
                                                 locked: false,
                                                 employee_amount: User.where(location_id: location_id).count,
                                                 training_minutes_available: 0,
                                                 training_minutes_accepted: 0,
                                                 training_minutes_per_employee: 0
                                             })
      new_ids += [vip_halls_train.id]
    end
    response_json new_ids
  end

  # GET /vip_halls_trains/field_options
  def field_options
    response_json VipHallsTrain.options
  end

  # GET /vip_halls_trains/options_of_all_locations
  def options_of_all_locations
    response_json Location.all
  end

  # GET /vip_halls_trains/which_locations_can_be_chosen
  def which_locations_can_be_chosen
    response_json Location.all.pluck('id') - VipHallsTrain
                          .where(train_month: Time.zone.parse(params[:train_month]))
                          .pluck('location_id')
  end

  # PATCH /vip_halls_trains/vip_halls_train_id/lock
  def lock
    authorize VipHallsTrain
    VipHallsTrain.find(params[:id]).update(locked: true)
    response_json
  end

  private
    # Only allow a trusted parameter "white list" through.
    def vip_halls_train_params
      params.require(:vip_halls_train).permit(*VipHallsTrain.create_params)
    end

    def search_query
      query = VipHallsTrain.includes(:location)
      {
          location_id: :by_location_id,
          train_month: :by_train_month,
      }.each do |key, value|
        query = query.send(value, params[key]) if params[key]
      end
      query
    end

end
