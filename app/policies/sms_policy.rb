class SmsPolicy < ApplicationPolicy
  power :send

  def delivery?
    can? :send
  end


  def self.chinese_name
    {send: '職位申請-發送短信'}
  end

  def self.english_name
    {send: 'send SMS'}
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
