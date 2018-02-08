# coding: utf-8
require "test_helper"

class ClassSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :ClassSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    ClassSettingsController.any_instance.stubs(:current_user).returns(user)
  end
  test "should get index" do
    [*1..2].each do |i|
      create(:department, id: i, chinese_name: "部門 #{i}")
    end

    [*1..20].each do |i|
      dept_id = i % 3 == 0 ? 1 : 2
      code = ClassSetting.where(department_id: dept_id).count + 1
      create(:class_setting, department_id: dept_id, code: code.to_s.rjust(3, '0'))
    end

    get '/class_settings'
    assert_response :success

    assert_equal [*1..20].select { |i| i % 3 == 0 }.count, json_res['data'].first['class_count']
    assert_equal [*1..20].select { |i| i % 3 == 0 }.count, json_res['data'].first['class_table'].count
    assert_equal json_res['data'].first['department_id'], json_res['data'].first['class_table'].first['department_id']
  end

  test 'should create' do
    department = create(:department)

    params = {
      region: 'macau',
      departments: [ department.id ],
      name: '班別 1',
      display_name: 'display name',
      start_time: '10:00',
      is_next_of_start: false,
      end_time: '16:00',
      is_next_of_end: false,
      late_be_allowed: 30,
      leave_be_allowed: 30,
      overtime_before_work: 20,
      overtime_after_work: 20
    }

    assert_difference(['ClassSetting.count'], 1) do
      post "/class_settings", params: params, as: :json
      assert_response :success
    end

    params = {
        region: 'macau',
        departments: [ department.id ],
        name: '班別 1',
        display_name: 'display name',
        #start_time: '10:00',
        is_next_of_start: false,
        end_time: '16:00',
        is_next_of_end: false,
        late_be_allowed: 30,
        leave_be_allowed: 30,
        overtime_before_work: 20,
        overtime_after_work: 20
    }

    assert_difference(['ClassSetting.count'], 1) do
      post "/class_settings", params: params, as: :json
      assert_response 422
      assert_equal json_res['data'][0]['message'], '參數不完整'
    end

  end

  test 'should update' do
    cs = create(:class_setting)

    params = {
      overtime_after_work: 0,
    }

    put "/class_settings/#{cs.id}", params: params, as: :json
    assert_response :success

    assert_equal 0, ClassSetting.first.overtime_after_work
  end

  test "should destroy" do
    cs = create(:class_setting)

    assert_difference(['ClassSetting.count'], -1) do
      delete "/class_settings/#{cs.id}"
      assert_response :success
    end
  end

  test "find code" do
    department = create(:department, id: 1)
    department_2 = create(:department, id: 2)

    [*1..10].each do |i|
      create(:class_setting, department_id: department.id, code: i.to_s.rjust(3, '0'))
    end

    assert_equal 10, ClassSetting.all.count

    temp_1 = ClassSetting.where(department_id: department.id, code: '003').first

    delete "/class_settings/#{temp_1.id}"
    assert_response :success

    temp_2 = ClassSetting.where(department_id: department.id, code: '007').first
    delete "/class_settings/#{temp_2.id}"
    assert_response :success

    temp_3 = ClassSetting.where(department_id: department.id, code: '008').first
    delete "/class_settings/#{temp_3.id}"
    assert_response :success

    assert_equal 7, ClassSetting.all.count
    assert_equal 0, ClassSetting.where(department_id: department.id, code: '003').count
    assert_equal 0, ClassSetting.where(department_id: department.id, code: '007').count
    assert_equal 0, ClassSetting.where(department_id: department.id, code: '008').count

    params = {
      region: 'macau',
      departments: [ department.id ],
      name: '新班別',
      display_name: 'new display name',
      start_time: '10:00',
      is_next_of_start: false,
      end_time: '16:00',
      is_next_of_end: false,
      late_be_allowed: 30,
      leave_be_allowed: 30,
      overtime_before_work: 20,
      overtime_after_work: 20
    }

    params_2 = {
      region: 'macau',
      departments: [ department.id, department_2.id ],
      name: '新班別',
      display_name: 'new display name',
      start_time: '10:00',
      is_next_of_start: false,
      end_time: '16:00',
      is_next_of_end: false,
      late_be_allowed: 30,
      leave_be_allowed: 30,
      overtime_before_work: 20,
      overtime_after_work: 20
    }

    assert_difference(['ClassSetting.count'], 1) do
      post "/class_settings", params: params, as: :json
      assert_response :success
    end

    assert_equal 8, ClassSetting.all.count
    assert_equal 1, ClassSetting.where(department_id: department.id, code: '003').count

    assert_difference(['ClassSetting.count'], 2) do
      post "/class_settings", params: params_2, as: :json
      assert_response :success
    end

    assert_equal 10, ClassSetting.all.count
    assert_equal 1, ClassSetting.where(department_id: department.id, code: '007').count
    assert_equal 1, ClassSetting.where(department_id: department_2.id, code: '008').count

    # assert_difference(['ClassSetting.count'], 1) do
    #   post "/class_settings", params: params, as: :json
    #   assert_response :success
    # end

    assert_equal 10, ClassSetting.all.count

    assert_difference(['ClassSetting.count'], 1) do
      post "/class_settings", params: params, as: :json
      assert_response :success
    end

    assert_equal 11, ClassSetting.all.count
    assert_equal 1, ClassSetting.where(department_id: department.id, code: '011').count
  end

  test "find code with char" do
    department = create(:department, id: 1)
    department_2 = create(:department, id: 2)
    department_3 = create(:department, id: 3)

    [*1..3].each do |i|
      if i != 3
        create(:class_setting, department_id: department.id, code: "T0#{i}")
      else
        create(:class_setting, department_id: department.id, code: i.to_s.rjust(3, '0'))
      end
    end

    assert_equal 3, ClassSetting.all.count

    params = {
      region: 'macau',
      departments: [ department.id, department_2.id, department_3.id ],
      name: '新班別',
      display_name: 'new display name',
      start_time: '10:00',
      is_next_of_start: false,
      end_time: '16:00',
      is_next_of_end: false,
      late_be_allowed: 30,
      leave_be_allowed: 30,
      overtime_before_work: 20,
      overtime_after_work: 20
    }

    assert_difference(['ClassSetting.count'], 3) do
      post "/class_settings", params: params, as: :json
      assert_response :success
    end

    assert_equal 6, ClassSetting.all.count
    assert_equal 1, ClassSetting.where(department_id: department.id, code: '001').count
    assert_equal 1, ClassSetting.where(department_id: department_2.id, code: '002').count
    assert_equal 1, ClassSetting.where(department_id: department.id, code: '003').count
    assert_equal 1, ClassSetting.where(department_id: department_3.id, code: '004').count
  end

  test "find code with non-num" do
    department = create(:department, id: 1)
    department_2 = create(:department, id: 2)
    department_3 = create(:department, id: 3)

    [*1..3].each do |i|
      create(:class_setting, department_id: department.id, code: "T0#{i}")
    end

    assert_equal 3, ClassSetting.all.count

    params = {
      region: 'macau',
      departments: [ department.id, department_2.id, department_3.id ],
      name: '新班別',
      display_name: 'new display name',
      start_time: '10:00',
      is_next_of_start: false,
      end_time: '16:00',
      is_next_of_end: false,
      late_be_allowed: 30,
      leave_be_allowed: 30,
      overtime_before_work: 20,
      overtime_after_work: 20
    }

    assert_difference(['ClassSetting.count'], 3) do
      post "/class_settings", params: params, as: :json
      assert_response :success
    end

    assert_equal 6, ClassSetting.all.count
    assert_equal 1, ClassSetting.where(department_id: department.id, code: '001').count
    assert_equal 1, ClassSetting.where(department_id: department_2.id, code: '002').count
    assert_equal 1, ClassSetting.where(department_id: department_3.id, code: '003').count
  end
end
