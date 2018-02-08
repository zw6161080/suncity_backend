module JobTransferPolicies
  def show?
    can? :view
  end

  def create?
    can? :view
  end
end