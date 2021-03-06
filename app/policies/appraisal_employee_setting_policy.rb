class AppraisalEmployeeSettingPolicy < ApplicationPolicy
  def index?
    can?  :appraisal_setting
  end

  def update?
    can?  :appraisal_setting
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
