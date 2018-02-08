require_relative '../../app/policies/concerns/attend_record_policies'
class HolidayRecordPolicy < ApplicationPolicy
  include AttendRecordPolicies

  def holiday_record_approval_for_employee?
    can? :view_for_approve
  end

  def holiday_record_approval_for_employee_export_xlsx?
    can? :view_for_approve
  end

  def holiday_record_approval_for_type?
    can? :view_for_approve
  end

  def holiday_record_approval_for_type_export_xlsx?
    can? :view_for_approve
  end

  def holiday_surplus_query?
    can? :view_for_surplus
  end

  def holiday_surplus_query_export_xlsx?
    can? :view_for_surplus
  end

  def index_for_report?
    can? :view_for_report
  end

  def export_xlsx_for_report?
    can? :view_for_report
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
