class MedicalReimbursementPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def export?
    can? :data
  end

  def create?
    can? :data
  end

  def update?
    can? :data
  end

  def destroy?
    can? :data
  end

  def send_message?
    can? :data
  end

  def download?
    can? :data
  end


  def create_from_profile?
    can? :update_information_from_profile
  end

  def update_from_profile?
    can? :update_information_from_profile
  end

  def destroy_from_profile?
    can? :update_information_from_profile
  end

  def download_from_profile?
    can? :update_information_from_profile
  end



  class Scope < Scope
    def resolve
      scope
    end
  end
end
