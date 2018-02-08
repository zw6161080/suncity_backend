class RolesController < ApplicationController

  def index
    authorize Role
    roles = Role.all

    response_json roles
  end

  def mine
    roles = current_user.roles

    response_json roles
  end

  def create
    role = Role.create(role_params)

    response_json role
  end

  def update
    authorize Role
    role = Role.find(params[:id])
    if !role.fixed
      role.update!(role_params)
      response_json
    else
      response_json '固定组禁止修改'
    end

  end

  def show
    role = Role.find(params[:id]).as_json(include: [ :permissions ])
    response_json role
  end

  def destroy
    role = Role.find(params[:id])

    if !role.fixed
      role.delete
      response_json
    else
      response_json '固定组禁止删除'
    end

  end

  def permissions
    permissions = Role.find(params[:id]).permissions

    response_json permissions
  end

  def add_permission
    role = Role.find(params[:id])


    if params[:permissions]
      params[:permissions].each do |p|
        role.add_permission_by_attribute(p[:action], p[:resource], p[:region])
      end
    end

    response_json role.permissions

  end

  def remove_permission
    role = Role.find(params[:id])

    if params[:permission_ids]
      params[:permission_ids].each do |p_id|
        permission = Permission.find_by_id(p_id)
        role.remove_permission(permission)
      end
    end

    if params[:permissions]
      params[:permissions].each do |p|
        role.remove_permission_by_attribute(p[:actions], p[:resource], p[:region])
      end
    end

    response_json

  end

  def users
    users = Role.find(params[:id]).users

    response_json users
  end

  def add_user
    role = Role.find(params[:id])

    if params[:user_ids]
      params[:user_ids].each do |user_id|
        role.add_user_by_id(user_id)
      end
    end

    response_json role.users
  end

  def remove_user
    role = Role.find(params[:id])

    if params[:user_ids]
      params[:user_ids].each do |u_id|
        role.remove_user_by_id(u_id)
      end
    end

    response_json role.users
  end

  private
  def role_params
    params.permit(:chinese_name, :english_name, :region)
  end
end
