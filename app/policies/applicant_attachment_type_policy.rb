class ApplicantAttachmentTypePolicy < ApplicationPolicy
  def index?
    can? :update, :attachment_type
  end

  def create?
    can? :update, :attachment_type
  end

  def show?
    can? :update, :attachment_type
  end

  def update?
    can? :update, :attachment_type
  end

  def destroy?
    can? :update, :attachment_type
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
