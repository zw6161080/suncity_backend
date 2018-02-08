# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  empoid              :string
#  chinese_name        :string
#  english_name        :string
#  password_digest     :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  position_id         :integer
#  location_id         :integer
#  department_id       :integer
#  id_card_number      :string
#  email               :string
#  superior_email      :string
#  company_name        :string
#  employment_status   :string
#  grade               :string
#  simple_chinese_name :string
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user with department' do
    user = create(:user)
    department = create(:department)
    user.department = department
    assert user.save
    user.reload
    assert_equal department.id, user.department_id
  end

  test 'render user profile id ' do
    profile = create_profile
    user = User.first
    assert_equal profile.id, user.profile_id
  end

  test 'user with location' do
    user = create(:user)
    location = create(:location)
    user.location = location
    assert user.save
    user.reload
    assert_equal location.id, user.location_id
  end

  test 'user with position' do
    user = create(:user)
    position = create(:position)
    user.position = position
    assert user.save
    user.reload
    assert_equal position.id, user.position_id
  end

  test 'head of department' do
    position = create(:position_with_full_relations)

    first_department = Department.first
    user = create(:user)
    user.position = position
    user.department = first_department
    user.grade = 6
    user.save

    first_department.reload
    assert_equal first_department.head.id, user.id

    position2 = create(:position, {
      grade: 1,
      department_ids: [first_department.id]
    })

    user2 = create(:user)
    user2.position = position2
    user2.department = first_department
    user2.grade = 5
    user2.save


    first_department.reload
    assert_equal first_department.head.id, user2.id

    assert_equal 2, first_department.employees.count
  end

  test 'of permissions' do
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    role = create(:role)
    role.add_permission_by_attribute(:create, :ApplicantProfile, :macau)
    role.add_user user1
    role.add_user user2

    users = User.of_permission(:create, :ApplicantProfile, :macau)
    assert users.include? user1
    assert users.include? user2
    assert_not users.include? user3
  end

  test 'create medical_insurance_participator' do
    user = create(:user)
    assert_equal user.id, MedicalInsuranceParticipator.where(user_id: user.id).first.user_id
    assert_equal 'not_participated', MedicalInsuranceParticipator.where(user_id: user.id).first.participate
    user.update(chinese_name: 'test')
    assert_equal User.count, MedicalInsuranceParticipator.count
  end
end
