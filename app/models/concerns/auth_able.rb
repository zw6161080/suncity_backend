# coding: utf-8
require 'net/ldap'
require 'net/ldap/dn'

module AuthAble
  module ClassMethods
    def auth(identity, password)
      auth_field = self::AUTH_FIELD
      user = self.find_by(auth_field => identity)
      if user != nil
        user_normal = user.auth(password)
        if user_normal != nil
          return user_normal
        end
      end
      auth_ldap(identity, password)
    end

    def auth_ldap(loginItem, password)
      ldap  = Net::LDAP.new
      ldap2 = Net::LDAP.new
      ldap.host = ldap2.host = HR_LDAP_SERVER_HOST
      ldap.port = ldap2.port = HR_LDAP_SERVER_PORT
      ldap.auth HR_LDAP_ACCOUNT_DN, HR_LDAP_ACCOUNT_PASS

      begin
        ldap.bind
      rescue => e
        raise LdapError, "登錄失敗，網絡故障，請重試: #{e.message}\n #{e.backtrace.join('\n')}"
      end

      filter = Net::LDAP::Filter.eq("sAMAccountName", loginItem) | Net::LDAP::Filter.eq("mail", loginItem)
      dn = ldap.search(base: "DC=suncity-group,DC=com", filter: filter, attributes: ["dn", "employeeid"], time: 5)

      raise LdapError, '登錄失敗，未找到該LDAP賬號，請聯繫HR' if dn == nil||dn == []

      dnn = dn.first.dn.to_s.force_encoding('UTF-8')
      employeeid = dn.first.employeeid.first.to_s.force_encoding('UTF-8')

      if !dnn.empty?
        ldap2.auth(dnn, password)
        raise LdapError, '登錄失敗，賬號或密碼錯誤，請重試' unless ldap.bind
        user = User.find_by_empoid(employeeid)
        raise LdapError, '登錄失敗，未找到您的檔案，請聯繫HR' if user.nil?
      end

      user
    end
  end

  module InstanceMethods
    def auth(password)
      self.authenticate password
    end

    def as_json(options={})
      opts = {except: ["password_digest"]}
      methods_with_params = options.delete(:methods_with_params)
      output = super(opts.merge(options || {}))
      if methods_with_params
        methods_with_params.each do |method|
          method = method.first
          output[method.first] = self.try(method.first, method.drop(1))
        end
      end
      output
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
