class RosterListPolicy < ApplicationPolicy
  def index?
    can? :view
  end

  def create?
    can? :view
  end

  def destroy?
    can? :view
  end

  def show?
    can? :view
  end

  def import_xlsx?
    can? :view
  end

  def roster_objects_export_xlsx?
    can? :view
  end

  def object_batch_update?
    can? :view
  end

  def to_draft?
    can? :view
  end

  def to_sealed?
    can? :view
  end

  def to_public?
    can? :view
  end

  def query_roster_objects?
    can? :view_for_search
  end

  def query_roster_objects_export_xlsx?
    can? :view_for_search
  end

  def department_roster_objects?
    can? :view_from_department
  end



  class Scope < Scope
    def resolve
      scope
    end
  end
end
