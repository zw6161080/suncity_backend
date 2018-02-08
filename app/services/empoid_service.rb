class EmpoidService
  def self.get(*args)
    new(*args).get
  end

  # get an empoid
  def get
    last_user = User.where('empoid ~ ?', "1\\d{7}").last

    last_empoid_no = nil
    if last_user
      last_empoid_no = last_user.empoid
    end

    empoid_no = '10000001'
    empoid_no = (last_empoid_no.to_i + 1).to_s if last_empoid_no

    empoid_no
  end
end
