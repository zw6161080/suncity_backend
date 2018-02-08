class AppraisalBasicSettingPolicy < ApplicationPolicy

  def show?
    can? :appraisal_setting
  end

  def update?
    can? :appraisal_setting
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
