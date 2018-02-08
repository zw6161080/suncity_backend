class ContractInformationPolicy < ApplicationPolicy
def index?
  can? :information
end

def create?
  can? :update_information
end


def update?
  can? :update_information
end

def destroy?
  can? :update_information
end

def download?
  can? :information
end

def preview?
  can? :information
end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
