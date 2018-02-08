module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include JsonWebTokenHelper
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
    def find_verified_user
      begin
        User.find(request_jwt_user_id)
      rescue
        reject_unauthorized_connection
      end
    end

    def request_jwt
      request.params['token']
    end

    def user_type
      @user_type ||= 'User'
    end

  end
end
