class BankAutoPayReportItemPolicy < ApplicationPolicy
  def index?
    can? :data_on_bank_auto_pay_report_item
  end

  def columns?
    can? :data_on_bank_auto_pay_report_item
  end

  def options?
    can? :data_on_bank_auto_pay_report_item
  end

  class Scope < Scope
    def resolve
      if (can? :data, :vp)
        scope
      else
        scope.where(users: {grade: [3, 4, 5, 6]})
      end
    end
  end
end
