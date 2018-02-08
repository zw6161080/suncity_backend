class EmailObjectPolicy < ApplicationPolicy
  power :send

  def delivery?
    can? :send
  end

  def self.chinese_name
    {send: '職位申請-發送郵件'}
  end

  def self.english_name
    {send: 'send emails'}
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
