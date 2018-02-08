module  AttendRecordPolicies
  def create?
    can? :view
  end

  def show?
    can? :view
  end

  def index?
    can? :view
  end

  def export_xlsx?
    can? :view
  end

  def update?
    can? :view
  end

  def destroy?
    can? :view
  end

  def add_approval?
    can? :view
  end

  def destroy_approval?
    can? :view
  end

  def destroy_attach?
    can? :view
  end

  def add_attach?
    can? :view
  end

  def download?
    can? :view
  end
end