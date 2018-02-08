# coding: utf-8
require 'test_helper'

class MessageServiceTest < ActiveSupport::TestCase

  setup do
    message_test_mock
  end


  test '消息发送测试' do
    m = Message.new
    m.content = "{\"title\":\"test content2\"}"
    m.namespace = Message::TASK_NAMESPACE
    m.target = @user_id
    assert m.save
    m = Message.new
    m.content = "{\"title\":\"test content3\"}"
    m.namespace = Message::TASK_NAMESPACE
    m.target = @user_id
    assert m.save
  #end

  #test '消息获取测试' do

    messages = MessageService.get_user_messages(@user_id, Message::TASK_NAMESPACE)

    assert_equal JSON.parse(@merged_message_response)['meta']['total'], messages[:meta][:total]
    assert_equal JSON.parse(@merged_message_response)['data'][0]['read_status'],messages[:data][0]['read_status']
    assert_equal JSON.parse(@merged_message_response)['data'][0]['content'], messages[:data][0]['content']
    assert_equal JSON.parse(@merged_message_response)['data'][0]['title'],messages[:data][0]['title']
    unread_messages = MessageService.get_user_unread_messages(@user_id, Message::TASK_NAMESPACE)
    assert_equal JSON.parse(@unread_message_response)['meta']['total'], unread_messages[:meta][:total]
  #end

  #test '获取未读消息数量' do
    unread_messages_count = MessageService.get_user_unread_messages_count(@user_id, Message::TASK_NAMESPACE)
    assert_equal JSON.parse(@unread_messages_count)['data'], unread_messages_count[:data]
  #end

  #test '读单条消息接口' do
    message_id = JSON.parse(@unread_message_response)['data'].first['id']
    assert MessageService.read_message(@user_id, message_id)
  #end

  #test '读取所有消息接口' do
    assert MessageService.read_all_messages(@user_id, Message::TASK_NAMESPACE)
  end
end
