class DepartureEmployeeTaxpayerNumberingReportItemPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def columns?
    can? :data
  end

  def options?
    can? :data
  end

  def update_beneficiary_name?
    can? :data
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
