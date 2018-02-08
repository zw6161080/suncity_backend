class ProfilePolicy < ApplicationPolicy
  power :manage, :create, :manage_missing

  def template?
    can? :manage
  end

  def index?
    can? :manage
  end

  def show?
    can? :manage
  end

  def export_xlsx?
    can? :export
  end

  def create?
    can? :create
  end

  def update?
  end

  def attachment_missing?
    can? :manage_missing
  end

  def attachment_missing_export?
    can? :manage_missing
  end

  def index_by_department?
    can? :view
  end

  def self.chinese_name
    {
      manage: '員工檔案-查看',
      create: '員工檔案-新增',
      manage_missing: '缺失入職文件'
    }
  end

  def self.english_name
    {
      manage: 'manage profiles',
      create: 'create profiles',
      manage_missing: 'manage missing profiles'
    }
  end

  class Scope < Scope
    def resolve
      if(can?(:data, :vp))
        scope
      else
        scope.joins(:user).where(users: {grade: [3, 4, 5, 6]})
      end
    end
  end
end
