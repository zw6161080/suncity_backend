require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    message_test_mock(@user.id)
    m = Message.new
    m.content = "{\"title\":\"hello world\"}"
    m.namespace = Message::TASK_NAMESPACE
    m.target = @user_id
    assert m.save
  end

  test 'get messages list' do
    get '/messages',
        params: { namespace: Message::TASK_NAMESPACE },
        headers: {
            Token: @user.token
        }
    assert_equal json_res['data'].first.fetch('content').fetch('title'), 'hello world'

    assert_response :ok
  end

  test 'get unread messages' do
    get '/messages/unread_messages',
        params: { namespace: Message::TASK_NAMESPACE },
        headers: {
            Token: @user.token
        }
    assert_equal json_res['data'].first.fetch('content').fetch('title'), 'hello world'
    assert_response :ok
  end

  test 'get unread messages count' do
    get '/messages/unread_messages_count',
        params: { namespace: Message::TASK_NAMESPACE },
        headers: {
            Token: @user.token
        }
    assert_response :ok
  end

  test 'read message' do
    message_id = JSON.parse(@unread_message_response)['data'].first['id']
    patch "/messages/#{message_id}/read",
          headers: {
              Token: @user.token
          }
    assert_response :ok
  end

  test 'read all messages' do
    patch '/messages/read_all',
          headers: {
              Token: @user.token
          }
    assert_response :ok
  end

end
