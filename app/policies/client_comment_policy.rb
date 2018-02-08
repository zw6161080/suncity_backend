class ClientCommentPolicy < ApplicationPolicy
  def index?
    can? :view
  end

  def show?
    can? :view
  end

  def create?
    can? :view
  end

  def update?
    can? :view
  end

  def show_tracker?
    can? :view
  end

  def columns?
    can? :view
  end

  def options?
    can? :view
  end



  class Scope < Scope
    def resolve
      scope
    end
  end
end
