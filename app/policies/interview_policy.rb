class InterviewPolicy < ApplicationPolicy
  power :manage, :cancel, :update, :complete

  def index?
    can? :manage
  end

  def create?
    can? :manage
  end

  def interviewers?
    can? :manage
  end

  def results?
    can?(:manage) || can?(:update)
  end

  def add_interviewers?
    can? :update
  end

  def remove_interviewers?
    can? :update
  end

  def update?
    can? :update
  end

  def completed?
    can? :complete
  end

  def cancelled?
    can? :cancel
  end

  def self.chinese_name
    {
      manage: '職位申請-預約面試',
      update: '職位申請-編輯面試',
      cancel: '職位申請-取消面試',
      complete: '職位申請-完成面試'
    }
  end

  def self.english_name
    {
      manage: 'view interviews',
      update: 'update interviews',
      cancel: 'cancel interviews',
      complete: 'complete interviews'
    }

  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
