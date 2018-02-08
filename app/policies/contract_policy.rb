class ContractPolicy < ApplicationPolicy
  power :manage, :cancel, :update

  def statuses?
    can? :manage
  end

  def create?
    can? :manage
  end

  def update?
    can? :update
  end

  def cancel?
    can? :cancel
  end

  def self.chinese_name
    {
      manage: "職位申請-預約簽約",
      cancel: '職位申請-取消簽約',
      update: '職位申請-編輯簽約'
    }
  end

  def self.english_name
    {
      manage: "view applicant contracts",
      cancel: 'cancel applicant contracts',
      update: 'update applicant contracts'
    }
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
