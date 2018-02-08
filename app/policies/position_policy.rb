class PositionPolicy < ApplicationPolicy
  power :create, :update, :disable

  def tree?
    can? :access_company_structure_management, :global
  end

  def create?
    can? :create
  end

  def update?
    can? :update
  end

  def disable?
    can? :disable
  end

  def self.chinese_name
    {
      create: '組織架構-新增職位',
      update: '組織架構-編輯職位',
      disable: '組織架構-啟用-禁用職位'
    }
  end

  def self.english_name
    {
      create: 'view positions list',
      update: 'update positions',
      disable: 'disable positions'
    }
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
