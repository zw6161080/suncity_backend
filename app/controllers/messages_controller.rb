class MessagesController < ApplicationController
  def index
    namespace = params[:namespace]
    # params[:page] = 1 if params[:page].to_s.to_i < 1
    messages = MessageService.get_user_messages(current_user_id, namespace, params[:page] || 1)
    response_json content_json_decode(messages[:data]), meta: messages[:meta]
  end

  def unread_messages
    namespace = params[:namespace]
    # params[:page] = 1 if params[:page].to_s.to_i < 1
    messages = MessageService.get_user_unread_messages(current_user_id, namespace, params[:page] || 1)
    response_json content_json_decode(messages[:data]), meta: messages[:meta]
  end

  def unread_messages_count
    namespace = params[:namespace]
    response = MessageService.get_user_unread_messages_count(current_user_id, namespace)
    response_json response[:data]
  end

  def read
    message_id = params[:id]
    MessageService.read_message(current_user_id, message_id)
    response_json
  end

  def read_all
    namespace = params[:namespace]
    MessageService.read_all_messages(current_user_id, namespace)
    response_json
  end

  private
  def content_json_decode(data_arr)
    result = []
    data_arr.each do |data|
      data['content'] = try_json_decode(data['content']) if data['content']
      result.push(data)
    end
    result
  end

  def try_json_decode(json)
    begin
      JSON.parse(json)
    rescue JSON::ParserError => e
      json
    end
  end
end
