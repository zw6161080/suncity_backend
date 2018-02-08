class AppraisalPolicy < ApplicationPolicy
  #支持-部门360评核
  #包括-评核详情
  #包括-评核名单记录详情
  #包括-问卷详情
  #包括-评核报告详情
  def show?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  #包括-评核详情
  #包括-绩效面谈记录
  def update?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  #包括-评核记录删除
  #包括-评核人名单记录删除
  def destroy?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  def initiate?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  def complete?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  def performance_interview?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  def performance_interview_check?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  def download?
    show_from_department?
  end
  #支持-部门360评核
  #包括-评核列表;评核人名单列表;问卷列表;评核报告列表;绩效面谈列表
  def index?
    (can? :view_from_department) || raw_show?
  end

  def index_by_distribution?
    (can? :view_from_department) || raw_show?
  end

  #支持-部门360评核
  def not_filled_participators?
    show_from_department?
  end
  #支持-部门360评核
  def departmental_confirm?
    show_from_department?
  end
  #支持-部门360评核
  def can_add_to_participator_list?
    show_from_department?
  end
  #支持-部门360评核
  #包括-评核人名单创建
  def create?
    show_from_department? || raw_show?
  end

  #支持-部门360评核
  #包括-评核人名单-添加评核人
  def create_assessor?
    show_from_department?
  end

  #支持-部门360评核
  #包括-评核人名单-删除评核人
  def destroy_assessor?
    show_from_department?
  end

  #支持-部门360评核
  def auto_assign?
    show_from_department?
  end
  #支持-部门360评核
  #包括-问卷表头
  def columns?
    show_from_department?
  end
  #支持-部门360评核
  #包括-问卷筛选项
  def options?
    show_from_department?
  end
  #支持-部门360评核
  def save?
    show_from_department?
  end
  #支持-部门360评核
  def submit?
    show_from_department?
  end
  #支持-部门360评核
  def revise?
    show_from_department?
  end
  #支持-部门360评核
  def side_bar_options?
    show_from_department?
  end
  #支持-部门360评核
  #支持-權限-評核記錄
  def record_options?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  #支持-權限-評核記錄
  def all_appraisal_report_record_columns?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  #支持-權限-評核記錄
  def all_appraisal_report_record?
    show_from_department? || raw_show?
  end
  #支持-部门360评核
  def completed?
    show_from_department?
  end
  #支持-部门360评核
  def complete_or_no?
    show_from_department?
  end

  #支持-權限-評核記錄
  def export?
    (can? :view_from_department) || raw_show?
  end

  def index_by_department?
    show_from_department?
  end

  def index_by_mine?
    true
  end

  def show_by_assessor?
    true
  end

  class Scope < Scope
    def resolve
      scope
    end
  end

  private
  def show_from_department?
    (can? :view_from_department)
  end

  def  raw_show?
    (can? :view)
  end
end
