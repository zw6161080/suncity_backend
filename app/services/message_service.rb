class MessageService
  class << self
    def create_message(message)
      # send_request('post', '/messages', message.as_json)
      mf = MessageInfo.create(content: message.content, target_type: message.target_type, targets: message.targets, namespace: message.namespace,
                              sender_id: message.sender_id).as_json
      mf['created_at'] = mf['created_at'].to_date.to_s

      self.broadcast(message, mf)
    end

    def get_user_messages(user_id, namespace, page = 1, per_page = 20)
      # send_request('get', "/users/#{user_id}/merged_messages", namespace: namespace, page: page, per_page: per_page)
      array = Array.new
      MessageStatus.where(:user_id => user_id).select("message_id").to_a.each do |hash|
        array.push(hash.message_id)
      end
      total=array.count


      m = MessageInfo.where(:id => array, :namespace => namespace).order(created_at: :desc).page.page(page.to_i - 1).per(per_page)
      array = Array.new
      m.as_json.each do |hash|

        date = hash['created_at'].to_s
        hash['created_at'] = date.split[0].split('-').join('/')+' '+date.split[1]
        hash.delete("targets")
        hash.delete("target_type")
        hash.delete("namespace")
        hash.delete("updated_at")
        if MessageStatus.where(:user_id => user_id,:message_id => hash['id']).select('has_read').as_json[0]['has_read']
          hash['read_status'] = 'read'
        else
          hash['read_status'] = 'unread'
        end
        hash['title'] = '' if hash['title'] == nil
        array.push(hash)
      end

      {:data => array, :meta => {:current => page, :total => total,:lastpage => (total / per_page + 1), :per_page => per_page}}
    end

    def get_user_unread_messages(user_id, namespace, page = 1, per_page = 20)
      # send_request('get', "/users/#{user_id}/unread_messages", namespace: namespace, page: page, per_page: per_page)
      array = Array.new
      MessageStatus.where(:user_id => user_id, :has_read => false).select("message_id").to_a.each do |hash|
        array.push(hash.message_id)
      end

      total = array.count
      m = MessageInfo.where(:id => array, :namespace => namespace).order(created_at: :desc).page(page.to_i - 1).per(per_page)
      array = Array.new
      m.as_json.each do |hash|
        hash['created_at'] = hash['created_at'].to_s
        hash.delete("targets")
        hash.delete("target_type")
        hash.delete("namespace")
        hash.delete("updated_at")
        hash['read_status'] = 'unread'
        hash['title'] = '' if hash['title'] == nil
        array.push(hash)

      end
      {:data => array, :meta => {:current => page, :total => total,:lastpage => (total / per_page + 1), :per_page => per_page}}
    end

    def get_user_unread_messages_count(user_id, namespace)
      # send_request('get', "/users/#{user_id}/unread_messages_count", namespace: namespace)

      result = MessageStatus.where(:user_id => user_id, :has_read => false, :namespace => namespace).select("message_id").count
      {:data => result}
    end

    def read_message(user_id, message_id)
      # send_request('post', '/messages/read', user_id: user_id, message_id: message_id)
      MessageStatus.where(:user_id => user_id, :message_id => message_id).update(has_read: true)
    end

    def read_all_messages(user_id, namespace)
      # send_request('post', '/messages/read_all', user_id: user_id, namespace: namespace)
      MessageStatus.where(:user_id => user_id, :namespace => namespace).update(has_read: true)
    end

    def request_url(endpoint)
      "#{message_server_base_url}#{endpoint}"
    end

    def message_server_base_url
      "http://#{ENV['MESSAGE_SERVER_HOST']}:#{ENV['MESSAGE_SERVER_PORT']}"
    end

    # def send_request(method, endpoint, params={})
    #  if method == 'get'
    #   response = RestClient.send(method, request_url(endpoint), {params: params})
    #  else
    #   response = RestClient.send(method, request_url(endpoint), params)
    #  end
    #  JSON.parse(response.body).with_indifferent_access
    # end

    def broadcast(message, mf)
      if message.targets.is_a?(Array)
        message.targets.each do |user_id|
          ActionCable.server.broadcast "message_#{user_id}", message: message.to_json
          MessageStatus.create(user_id: user_id, message_id: mf["id"], namespace: message.namespace)
        end
      elsif message.target_type == Message::USER_TARGET
        ActionCable.server.broadcast "message_#{message.target}", message: message.to_json

      elsif message.target_type == Message::GLOBAL_TARGET
        ActionCable.server.broadcast "message_global", message: message.to_json
        User.find_each do |user|
          MessageStatus.create(user_id: user.id, message_id: mf["id"], namespace: message.namespace)
        end
      end
    end

  end
end