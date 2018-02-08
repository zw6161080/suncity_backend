module TrainShowPolicies
  def introduction?
    show?
  end

  def entry_lists?
    show?
  end

  def online_materials?
    show?
  end

  def final_lists?
    show?
  end

  def sign_lists?
    show?
  end

  def result?
    show?
  end

  def result_index?
    show?
  end

  def result_evaluation?
    show?
  end

  def update_result_evaluation?
    show?
  end

  def has_been_published?
    show?
  end

  def update?
    show?
  end

  def cancel?
    show?
  end

  def cancelled?
    show?
  end

  #邀請員工報名
  def create_entry_lists?
    show?
  end

  def sign_lists?
    show?
  end

  def create_training_papers?
    show?
  end

  def create_student_evaluations?
    show?
  end

  def create_supervisor_assessment?
    show?
  end

  def completed?
    show?
  end

  def entry_lists_with_to_confirm?
    show?
  end

  private

  def show?
    can? :view_from_department
  end


end