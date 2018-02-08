module  AttendReportPolicies
  def index_for_report?
    can? :view_for_report
  end

  def export_xlsx_for_report?
    can? :view_for_report
  end
end
