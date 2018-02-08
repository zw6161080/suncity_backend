module GetProfileInformationHelper
  def get_grade(profile)
   profile.user.grade rescue nil
  end
end