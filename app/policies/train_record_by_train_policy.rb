class TrainRecordByTrainPolicy < ApplicationPolicy
  def index?
    can? :view_record
  end

  def export?
    can? :view_record
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
