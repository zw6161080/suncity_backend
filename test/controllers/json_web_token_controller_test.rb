require 'test_helper'

class JsonWebTokenControllerTest < ActionDispatch::IntegrationTest
  test '用户通过正确的账号密码换取jwt' do
    user = create(:user)
    assert_equal user, User.auth(user.empoid, '123456')

    params = {
      identity: user.empoid,
      password: '123456'
    }

    post '/json_web_token', params: params
    res = json_res
    assert res['data'].key?('token')
    assert res['data'].key?('profile_id')

    params = {
      identity: 'some identity',
      password: 'some password'
    }

    post '/json_web_token', params: params
    assert_equal '登錄失敗，網絡故障，請重試', json_res['data'].first
  end

  test 'token过期处理' do
    user = create(:user)

    payload = {
        self.class.name => {
            :user_id => user.id
        },
        'exp' => 1.second.ago.to_i
    }

    token_expired = JWT.encode(payload, ENV["SECRET_KEY_BASE"])
    assert_raise(JWT::ExpiredSignature) do
      JWT.decode(token_expired, ENV["SECRET_KEY_BASE"])
    end
  end
end
