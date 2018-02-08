class LocationsController < ApplicationController
  #List all locations
  def index
    locations_query = Location.all.list

    if params[:region]
      locations_query = locations_query
                          .where('locations.region_key = ?', params[:region])
    end

    if params[:position_id]
      locations_query = locations_query
                          .joins(:positions)
                          .where('positions.id = ?', params[:position_id])
    end

    if params[:department_id]
      locations_query = locations_query
                          .joins(:departments)
                          .where('departments.id = ?', params[:department_id])
    end
    response_json locations_query.as_json(methods: :key)
  end


  def all_locations
    response_json Location.all.as_json(methods: [:key, :can_be_destroyed_on_tree?, :can_be_updated_on_tree?])
  end

  #Get Tree Struct of Locations
  def tree
    tree = Location.to_tree
    response_json tree
  end

  def with_departments
    response_json Location.with_departments
  end

  def create
    parent_location = nil

    if params[:parent_id]
      parent_location = Location.find(params[:parent_id])
    end
    if Location.where(chinese_name: params[:chinese_name]).count > 0
      response_json "用户名已存在", {error: 422}
      return
    end
    if Location.where(english_name: params[:english_name]).count > 0
      response_json "英文名已存在", {error: 422}
      return
    end
    if Location.where(simple_chinese_name: params[:simple_chinese_name]).count > 0
      response_json "简体中文名已存在", {error: 422}
      return
    end
    location = Location.create(location_params)
    if parent_location
      parent_location.children << location
    end

    response_json
  end

  def update
    parent_location = nil

    if params[:parent_id]
      parent_location = Location.find(params[:parent_id])
    end

    location = Location.find(params[:id])
    location.update!(location_params)

    if parent_location
      parent_location.children << location
    end

    response_json
  end

  def show
    location = Location.find(params[:id])
    response_json location
  end

  def destroy
    location = Location.find(params[:id])
    if location.departments.count > 0 ||
        location.positions.count > 0 ||
        location.rosters.count > 0 ||
        location.attendances.count > 0
      response_json '场馆下有下属部门/职位/排班表/考勤表，不可删除' , {error: 422}
    else
      location.delete
      response_json
    end
  end

  def location_children

    locations = []
    locations_query = Location.all
    if params[:region]
      locations_query = locations_query
                            .where('locations.region_key = ?', params[:region])
    end
    locations_query.each{ |record|
      if record.children.empty?
        locations.push record
      end
    }
    response_json locations.as_json(methods: :key)
  end

  def location_children_with_parent
    locations_query = Location.all

    if params[:region]
      locations_query = locations_query
                            .where('locations.region_key = ?', params[:region])
    end

    if params[:position_id]
      locations_query = locations_query
                            .joins(:positions)
                            .where('positions.id = ?', params[:position_id])
    end

    if params[:department_id]
      locations_query = locations_query
                            .joins(:departments)
                            .where('departments.id = ?', params[:department_id])
    end
    locations = []
    locations_query.each{ |record|
      unless record.parent.nil?
        locations.push (record.parent)
      end
    }
    locations_query.each{ |record|
        locations.push (record)
    }
    locations = locations.uniq
    response_json locations.as_json(methods: :key)
  end

  private

  def location_params
    if params.require(:location)[:location_type] == 'office'
      raise 'location_type can not be office'
    end
    params.require(:location).permit(:chinese_name, :english_name, :simple_chinese_name, :region_key, :location_type)
  end
end
