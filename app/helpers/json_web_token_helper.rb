module JsonWebTokenHelper
  #获取jwt的payload数据
  def jwt_claim(jwt)
    raise AuthError, '未授权的请求' if jwt.blank?
    begin
      JWT.decode(jwt, ENV["SECRET_KEY_BASE"])
    rescue JWT::ImmatureSignature
      raise AuthError, '未授权的请求'
    rescue JWT::ExpiredSignature
      raise TokenExpireError, 'Token已过期'
    end
  end

  #获取payload中的user id
  def jwt_user_id(jwt_claim, auth_type=nil)
    unless auth_type
      auth_type = user_type
    end

    begin
      jwt_claim[0][auth_type]["user_id"]
    rescue
      raise AuthError, '未授权的请求'
    end
  end

  def request_jwt_user_id
    jwt_user_id(jwt_claim(request_jwt))
  end
end
