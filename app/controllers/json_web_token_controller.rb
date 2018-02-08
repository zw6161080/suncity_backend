class JsonWebTokenController < ApplicationController
  def create
    user = User.auth(params[:identity], params[:password])

    raise_logic_error(101) unless user

    res = user.as_json(methods: [:token, :profile_id])
    response_json res
  end
end
