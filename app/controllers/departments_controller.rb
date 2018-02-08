class DepartmentsController < ApplicationController
  wrap_parameters include: Department.attribute_names.push('location_ids')

  def with_positions
    render json: Department.all.as_json(include: :positions)
  end

  def index
    depearment_query = Department.precount(:employees)
                                 .includes(:head)

    unless params[:with_disabled]
      depearment_query = depearment_query.where(status: :enabled)
    end

    if params[:region]
      depearment_query = depearment_query
                          .where('departments.region_key = ?', params[:region])
    end

    if params[:position_id]
      depearment_query = depearment_query
                          .joins(:positions)
                          .where('positions.id = ?', params[:position_id])
    end

    if params[:location_id]
      depearment_query = depearment_query
                          .joins(:locations)
                          .where('locations.id = ?', params[:location_id])
    end
    response_json depearment_query.as_json(include: :head, methods: [:employees_count, :head, :key, :positions_count, :heads])
  end

  def index_with_Pending
    depearment_query = Department.precount(:employees)
                           .includes(:head)
    unless params[:with_disabled]
      depearment_query = depearment_query.where(status: :enabled)
    end
    if params[:region]
      depearment_query = depearment_query
                             .where('departments.region_key = ?', params[:region])
    end
    if params[:position_id]
      depearment_query = depearment_query
                             .joins(:positions)
                             .where('positions.id = ?', params[:position_id])
    end
    if params[:location_id]
      depearment_query = depearment_query
                             .joins(:locations)
                             .where('locations.id = ?', params[:location_id])
    end
    data=depearment_query.as_json(methods: [:employees_count, :head, :key, :positions_count])
    data.unshift({id:'pending', chinese_name:'待定', english_name:'To be determined', simple_chinese_name:'待定', key: 'pending'})
    response_json data
  end


  def tree
    authorize Department
    response_json Department.to_tree
  end

  def create
    authorize Department
    parent_department = nil

    if params[:parent_id]
      parent_department = Department.find(params[:parent_id])
    end

    department = Department.create(department_params)

    if parent_department
      parent_department.children << department
    end

    if department.valid?
      response_json department
    else
      response_json department.errors
    end
  end

  def update
    authorize Department
    parent_department = nil

    if params[:parent_id]
      parent_department = Department.find(params[:parent_id])
    end

    department = Department.find(params[:id])
    department.update!(department_params)

    if parent_department
      parent_department.children << department
    end

    response_json
  end

  def show
    department = Department.find(params[:id])
    response_json department.as_json(methods: :location_ids)
  end

  def enable
    department = Department.find(params[:id])
    department.enabled!
    response_json
  end

  def disable
    authorize Department
    department = Department.find(params[:id])
    department.disabled!
    response_json
  end

  def profiles
    department = Department.find(params[:id])
    profiles = Profile.not_stashed.joins(:user).where('users.department_id = ?', department)

    if params[:grade]
      profiles = profiles.where('users.grade = ?', params[:grade])
    end

    profiles = profiles.order("users.empoid")

    if params[:select_columns]
      select_columns = params[:select_columns]
    else
      if params[:subordinate]
        select_columns = SelectColumnTemplate.default_select_columns
      else
        select_columns = SelectColumnTemplate.default_columns(region: params[:region])
      end
    end

    #unshift photo to fields
    select_columns.unshift('photo')
    fields = Field.find_in(select_columns)

    result = {
      fields: fields.as_json,
      profiles: profiles.map{|profile|
        {id: profile.id}.merge(profile.as_json_only_fields(select_columns))
      }
    }

    response_json result
  end

  def positions
    department = Department.find(params[:id])

    response_json department.positions
  end

  private
  def department_params
    params.require(:department).permit(:chinese_name, :english_name, :simple_chinese_name, :region_key, :comment, {:location_ids => []})
  end
end
