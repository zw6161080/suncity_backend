# coding: utf-8
class SuncitySmsService
  class << self
    def send_msg(to, content)
      #判断手机号格式
      #8位纯数字
      if (/^\d{8}$/ =~ to)
        to = '+853-' + to
      #11位纯数字
      elsif (/^\d{11}$/ =~ to)
        to = '+86-' + to
      #少 ‘ - ’ 的情况
      elsif (/^\+853\d{8}$/ =~ to)
        to.insert(4, '-')
      elsif (/^\+86\d{11}$/ =~ to)
        to.insert(3, '-')
      end

      #接口地址
      url = SMS_URL

      postData = {
        username: SMS_USER_NAME,
        password: SMS_PASSWORD,
        content: content,
        number: to,
        roomId: SMS_ROOM_ID
      }
      RestClient.send('post', url, postData)
    end
  end
end
