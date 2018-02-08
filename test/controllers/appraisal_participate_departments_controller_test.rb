require 'test_helper'

class AppraisalParticipateDepartmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location1 = create(:location, chinese_name: '辦公室')
    @location2 = create(:location, chinese_name: '新葡京')

    @department1 = create(:department, chinese_name: '行政及人力資源部')
    @department2 = create(:department, chinese_name: '資訊科技部')
    @department3 = create(:department, chinese_name: '市場策劃部')

    # @position1 = create(:position, chinese_name: '高級經理')
    # @position2 = create(:position, chinese_name: 'IT员工')
    # @position3 = create(:position, chinese_name: '市场调研员')
    #
    # @user1 = create(:user, empoid: '111', chinese_name: '呂國敏', grade: 1, location_id: @location1.id, department_id: @department1.id, position_id: @position1.id)
    # @user2 = create(:user, empoid: '222', chinese_name: '范冰冰', grade: 3, location_id: @location1.id, department_id: @department2.id, position_id: @position2.id)
    # @user3 = create(:user, empoid: '333', chinese_name: '苏妲己', grade: 5, location_id: @location1.id, department_id: @department3.id, position_id: @position3.id)
    #
    # @user4 = create(:user, empoid: '444', chinese_name: '林志玲', grade: 1, location_id: @location2.id, department_id: @department1.id, position_id: @position1.id)
    # @user5 = create(:user, empoid: '555', chinese_name: '黎女士', grade: 4, location_id: @location2.id, department_id: @department3.id, position_id: @position3.id)
    # @user6 = create(:user, empoid: '666', chinese_name: '冯德伦', grade: 4, location_id: @location2.id, department_id: @department3.id, position_id: @position3.id)

    @appraisal1 = create(:appraisal, appraisal_status: :unpublished,    appraisal_name: '公司員工2017年第一期評核', date_begin: '2017/01/01', date_end: '2017/01/15', participator_amount: 1000)
    @appraisal2 = create(:appraisal, appraisal_status: :to_be_assessed, appraisal_name: '公司員工2017年第二期評核', date_begin: '2017/04/01', date_end: '2017/04/15', participator_amount: 2000)
    @appraisal3 = create(:appraisal, appraisal_status: :assessing,      appraisal_name: '公司員工2017年第三期評核', date_begin: '2017/07/01', date_end: '2017/07/15', participator_amount: 1000)
    @appraisal4 = create(:appraisal, appraisal_status: :completed,      appraisal_name: '公司員工2017年第四期評核', date_begin: '2017/10/01', date_end: '2017/10/15', participator_amount: 2000)

    @appraisal_participate_department = create(:appraisal_participate_department, appraisal_id: @appraisal1.id, location_id: @location1.id, department_id: @department1.id, confirmed: false, participator_amount: 89)
    create(:appraisal_participate_department, appraisal_id: @appraisal1.id, location_id: @location1.id, department_id: @department2.id, confirmed: false, participator_amount: 42)
    create(:appraisal_participate_department, appraisal_id: @appraisal1.id, location_id: @location1.id, department_id: @department3.id, confirmed: true,  participator_amount: 176)
    create(:appraisal_participate_department, appraisal_id: @appraisal1.id, location_id: @location2.id, department_id: @department1.id, confirmed: true,  participator_amount: 99)
    create(:appraisal_participate_department, appraisal_id: @appraisal1.id, location_id: @location2.id, department_id: @department2.id, confirmed: false, participator_amount: 21)
    create(:appraisal_participate_department, appraisal_id: @appraisal1.id, location_id: @location2.id, department_id: @department3.id, confirmed: true,  participator_amount: 100)
  end

  def test_index
    get appraisal_participate_departments_url, params: { appraisal_id: @appraisal1.id }
    assert_response :success
  end

  def test_update
    patch appraisal_participate_department_url(@appraisal_participate_department.id), params: { appraisal_participate_department: { confirmed: true } }
    assert_response 200
    assert_equal true, AppraisalParticipateDepartment.find(@appraisal_participate_department.id).confirmed
  end

  def test_show
    # 当部门主管访问详情页时，只显示所在部门的信息
    get appraisal_participate_department_url(@appraisal_participate_department.id)
    assert_response 200
  end

end
