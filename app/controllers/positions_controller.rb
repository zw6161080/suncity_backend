class PositionsController < ApplicationController
  wrap_parameters include: Position.attribute_names.push('location_ids').push('department_ids')

  def index
    positions_query = Position

    unless params[:with_disabled]
      positions_query = positions_query.where(status: :enabled)
    end

    if params[:region]
      positions_query = positions_query
                          .where('positions.region_key = ?', params[:region])
    end

    if params[:department_id]
      positions_query = positions_query
                          .joins(:departments)
                          .where('departments.id = ?', params[:department_id])
    end

    if params[:location_id]
      positions_query = positions_query
                          .joins(:locations)
                          .where('locations.id = ?', params[:location_id])
    end

    response_json positions_query.as_json(methods: [:key, :employees_count])
  end
  def position_with_department
    if params[:department_id]
      positions_query = Position
      unless params[:with_disabled]
        positions_query = positions_query.where(status: :enabled)
      end
      if params[:region]
        positions_query = positions_query
                              .where('positions.region_key = ?', params[:region])
      end
      if params[:location_id]
        positions_query = positions_query
                              .joins(:locations)
                              .where('locations.id = ?', params[:location_id])
      end
      positions_query = positions_query
                            .joins(:departments)
                            .where('departments.id = ?', params[:department_id])
      data=Job.where('department_id =?', params[:department_id].to_i).pluck(:position_id)
      response_json positions_query.select{|p| !data.include?(p[:id].to_i)}.as_json(methods: [:key, :employees_count])
    else
      index
    end
  end

  def tree
    response_json Position.to_tree
  end

  def create
    authorize Position
    parent_position = nil

    if params[:parent_id]
      parent_position = Position.find(params[:parent_id])
    end

    position = Position.create(position_params)

    if parent_position
      parent_position.children << position
    end

    response_json
  end

  def update
    authorize Position
    parent_position = nil

    if params[:parent_id]
      parent_position = Position.find(params[:parent_id])
    end

    position = Position.find(params[:id])
    position.update!(position_params)

    if parent_position
      parent_position.children << position
    end

    response_json
  end

  def show
    position = Position.find(params[:id])
    response_json position.as_json(methods: [:location_ids, :department_ids])
  end

  def enable
    position = Position.find(params[:id])
    position.enabled!
    response_json
  end

  def disable
    authorize Position
    position = Position.find(params[:id])
    position.disabled!
    response_json
  end

  private
  def position_params
    params.require(:position).permit(
      :chinese_name,
      :english_name,
      :simple_chinese_name,
      :grade,
      :comment,
      :region_key,
      location_ids: [],
      department_ids: []
    )
  end
end
