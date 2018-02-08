class DepartmentPolicy < ApplicationPolicy
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
        create: '組織架構-新增部門',
        update: '組織架構-編輯部門',
        disable: '組織架構-啟用-禁用部門'
    }
  end

  def self.english_name
    {
        create: 'create departments',
        update: 'update departments',
        disable: 'disable departments'
    }
  end

  def self.simple_chinese_name
    {
        create: '组织架构-新增部门',
        update: '组织架构-编辑部门',
        disable: '组织架构-启用-禁用部门'
    }
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
