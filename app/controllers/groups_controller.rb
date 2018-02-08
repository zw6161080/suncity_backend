class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :destroy, :can_destroy]

  # GET /groups
  def index
    query = Group.all
    render json: query, root: 'data'
  end

  def options_for_profile_create
    query =  Group.by_department_id(params[:department_id])
    render json: query, root: 'data'
  end

  # POST /groups
  def create
    group = Group.new(group_params)
    if group.save
      group.departments << Department.where(id: params[:departments])
      render json: group, status: :created, location: group
    else
      render json: group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    # check can update directly
    used_departments = User.where(department_id: @group.departments.select(:id)).where(group_id: @group.id).collect(&:department_id).uniq.compact
    if (params[:departments].map(&:to_i) & used_departments) != used_departments
      render json: { update: false, departments: Department.where(id: used_departments) }
      return
    end
    if @group.update(group_params)
      @group.departments.clear
      @group.departments << Department.where(id: params[:departments])
      render json: { update: true, group: @group }
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    unless CareerRecord.pluck(:group_id).include?(@group.id)
      @group.departments.clear
      User.where(group_id: @group.id).each do |user|
        profile = user.profile
        profile.send(
          :edit_field, {field: 'group', new_value: nil, section_key: 'position_information'}.with_indifferent_access
        )
        profile.save
        user.update_column(:group_id, nil)
      end
      render json: @group.destroy
    end
  end

  def can_destroy
    render json: {can_destroy: !CareerRecord.pluck(:group_id).include?(@group.id)}
  end

  private
    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:chinese_name)
      params.require(:english_name)
      params.require(:simple_chinese_name)
      params.require(:departments)
      params.permit(:chinese_name, :english_name, :simple_chinese_name)
    end
end
