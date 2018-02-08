class CardProfilePolicy < ApplicationPolicy

  def index?
    can? :view
  end

  def translate?
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

  def matching_search?
    can? :view
  end

  def export_xlsx?
    can? :view
  end

  def current_card_profile_by_user?
    can? :information
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
