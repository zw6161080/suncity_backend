require_relative 'concerns/train_show_policies'
class TrainPolicy < ApplicationPolicy
  include TrainShowPolicies

  def index?
    can? :manage
  end
  def trains_info_by_user?
    can? :information
  end

  def index_by_department?
    can? :view_from_department
  end

  #部門主管報名頁
  def train_entry_lists?
    can? :view_from_department
  end
  #部門主管報名頁，提交
  def create_entry_lists?
    can? :view_from_department
  end

  #培训记录-培训日历
  def train_classes?
    (can? :view_record) || show?
  end
  #培训记录-员工参加培训明细
  def all_trains?
    can? :view_record
  end
  #培训记录按部门
  def records_by_departments?
    can? :view_record
  end
  #全部记录
  def all_records?
    can? :view_record
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
  private

  def show?
    (can? :view_from_department) || (can? :manage)
  end

end
