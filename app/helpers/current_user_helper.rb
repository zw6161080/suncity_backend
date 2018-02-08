module CurrentUserHelper
  include JsonWebTokenHelper

  #客户端发来的jwt
  def request_jwt
    request.headers["Token"]
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user = User.find_by :id => request_jwt_user_id 
    @current_user.current_region = current_region
    @current_user
  end

  def user_type
    @user_type ||= 'User'
  end

  def current_region
    request.headers["Region"]
  end

  alias_method :current_user_id, :request_jwt_user_id
end
