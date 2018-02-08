class EntryListPolicy < ApplicationPolicy

  def create?
    show?
  end

  def batch_update_and_to_final_lists?
    show?
  end


  class Scope < Scope
    def resolve
      scope
    end
  end

  private
  def show?
    can? :view_from_department
  end
end
