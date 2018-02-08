class PermissionsController < ApplicationController

  # def index
  #   permissions = Permission
  #   permissions = permissions.where(resource: params[:resources]) if params[:resources]
  #   permissions = permissions.all

  #   response_json permissions
  # end

  # def update
  #   permission = Permission.find(params[:id])
  #   permission.update!(permission_params)

  #   response_json
  # end

  # def show
  #   permission = Permission.find(params[:id])

  #   response_json permission
  # end

  def policies
    policies = params[:with_translations] ? Permission.policies_translations : Permission.policies

    response_json policies
  end

  # private
  # def permission_params
  #   params.permit(:chinese_name, :english_name)
  # end

end
