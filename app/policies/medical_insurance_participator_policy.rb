class MedicalInsuranceParticipatorPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def export?
    can? :data
  end

  def update_from_profile?
    can? :update_information_from_profile
  end

  def update?
    can? :data
  end

  def show?
    can? :information
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
