class ApplicationController < ActionController::API
  rescue_from LogicError, with: :logic_error_handler
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_handler
  rescue_from AuthError, with: :auth_error_handler
  rescue_from LdapError, with: :ldap_error_handler
  rescue_from TokenExpireError, with: :token_expire_error_handler
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_locale

  include JsonResponseHelper
  include CurrentUserHelper
  include Pundit

  # disable active model serializers default serialization scope 'current_user'
  serialization_scope nil

  private
  def logic_error_handler(error)
    response_json JSON.parse(error.message), error: true
  end

  def record_invalid_handler(exception)
    response_json exception.message, error: true
  end

  def auth_error_handler(error)
    Rails.logger.error "Token With 401: #{request_jwt}"
    response_json error.message, error: 401
  end

  def ldap_error_handler(error)
    Rails.logger.error "LDAP login error"
    response_json error.message, error: 401
  end

  def token_expire_error_handler(error)
    response_json 'token_expire', error: 401
  end

  def raise_logic_error(error_key)
    error = Config.get('api_errors')[error_key]
    error['id'] = error_key
    error['message'] = I18n.t("errors.#{error['key']}")

    raise LogicError, error.to_json
  end

  def user_not_authorized
    error_message = "You are not authorized to perform this action."
    response_json error_message, error: 403
  end

  def set_locale
    # I18n.locale = params[:locale] || I18n.default_locale
    I18n.locale = 'zh-HK'
    case params[:locale]
      when 'en-US','en' then
        I18n.locale = 'en'
      when 'zh-CN' then
        I18n.locale = 'zh-CN'
    end
  end

  def select_language
    if I18n.locale == 'zh-HK'.to_sym
      :chinese_name
    elsif I18n.locale == 'zh-CN'.to_sym
      :simple_chinese_name
    else
      :english_name
    end
  end
end
