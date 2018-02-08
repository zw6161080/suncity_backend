class MedicalItemTemplatePolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def create?
    can? :data
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
