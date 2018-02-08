class UsersController < ApplicationController
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  include SortParamsHelper

  def index
    response_json User.all.as_json(methods: [:key ], except: :password_digest )
  end

  def roles
    authorize User
    roles = User.find(params[:id]).roles.as_json(include: [ :permissions ])

    response_json roles
  end

  def add_role
    authorize User
    user = User.find(params[:id])
    role_ids = params[:role_ids]
    Array(role_ids).each do |role_id|
      role = Role.find(role_id)
      user.add_role(role)
    end
    
    roles = User.find(params[:id]).roles.as_json(include: [ :permissions ])

    response_json roles
  end

  def remove_role
    authorize User
    user = User.find(params[:id])
    role = Role.find(params[:role_id])
    user.remove_role(role)

    response_json
  end

  def permissions
    permissions = User.find(params[:id]).permissions
    response_json permissions
  end

  def get_user_group_by_position_id
    users =  User.where("grade <= '2'").select("chinese_name, english_name, id, empoid, position_id, grade")
    response_json users.group_by { |item| item["position_id"] }.as_json
  end

end
