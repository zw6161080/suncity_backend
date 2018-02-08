module MineCheckHelper
  def look_myself_by_user?(user)
    current_user.id == user.id if user
  end

  def look_myself_by_users?(users)
    users.ids.include? current_user.id if users
  end

  def myself?
    unless look_myself_by_user?(@user) || look_myself_by_users?(@users)
      render json: {meassge: "not current_user's information"}, status: 403
    end
  end

  def entry_from_mine?
    params[:entry] == 'mine'
  end

  def entry_from_department?
    params[:entry]  == 'department'
  end
end