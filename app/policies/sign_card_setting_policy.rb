class SignCardSettingPolicy < ApplicationPolicy

  def index?
    can? :setting
  end
  def update?
    can? :setting
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
