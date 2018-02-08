# == Schema Information
#
# Table name: jobs
#
#  id                :integer          not null, primary key
#  department_id     :integer
#  position_id       :integer
#  superior_email    :string
#  grade             :string
#  number            :integer
#  chinese_range     :text
#  english_range     :text
#  chinese_skill     :text
#  english_skill     :text
#  chinese_education :text
#  english_education :text
#  status            :integer          default("enabled")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  region            :string
#  need_number       :integer
#

require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "compute need number" do
    job = create(:job)
    position = create(:position)
    Job.any_instance.stubs(:position).returns(position)
    Job.any_instance.stubs(:position_profiles_count).returns(5)
    job.number = 9
    job.save

    assert 4, job.reload.need_number
  end

  test "recaculate_need_number" do
    position = create(:position)
    department = create(:department)
    job = create(:job, position_id: position.id, department_id: department.id, number: 10)

    7.times do
      create(:user, position_id: position.id, department_id: department.id)
    end

    assert_equal 3, job.reload.need_number
    assert_equal job.status.to_s, "enabled"

    3.times do
      create(:user, position_id: position.id, department_id: department.id)
    end

    assert_equal 0, job.reload.need_number
    assert_equal job.status.to_s, "disabled"
  end

end
