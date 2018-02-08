class UserPolicy < ApplicationPolicy

  def roles?
    user.can?(:index, :Role)
  end

  def add_role?
    user.can?(:update, :Role)
  end

  def remove_role?
    user.can?(:update, :Role)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
