class AgreementFilePolicy < ApplicationPolicy
  power :manage, :destroy, :download


  def generate?
    can? :manage
  end


  
  def destroy?
    can? :destroy
  end

  def download?
    can? :download
  end

  def self.chinese_name
    {
      manage: '職位申請-生成合約',
      destroy: '職位申請-刪除合約',
      download: '職位申請-匯出合約'
    }
  end

  def self.english_name
    {
      manage: 'manage agreement files',
      destroy: 'destroy agreement file',
      download: 'download agreement file'
    }

  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
