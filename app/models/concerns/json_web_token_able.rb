module JsonWebTokenAble
  def to_jwt
    payload = {
        self.class.name => {
            :user_id => self.id
        },
        'exp' => 1.month.from_now.to_i
    }
    JWT.encode(payload, ENV["SECRET_KEY_BASE"])
  end

  alias_method :token, :to_jwt
end