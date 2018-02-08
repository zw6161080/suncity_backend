require 'test_helper'

class ProvidentFundsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_user = create_test_user
    @test_profile = @test_user.profile
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:information, :ProvidentFund, :macau)
    @admin_role.add_permission_by_attribute(:data, :provident_fund, :macau)
    @test_user.add_role(@admin_role)
    ProvidentFundsController.any_instance.stubs(:current_user).returns(@test_user)
    User.any_instance.stubs(:career_entry_date).returns(Time.zone.now)
    @another_user = create_test_user
  end

  test 'get show without provident_fund_information' do
    @test_user.add_role(@admin_role)
    get "/profiles/#{@test_profile.id}/provident_fund"
    assert_response :ok
    assert_nil json_res['data']
  end

  test 'get show with provident_fund_information' do
    @test_profile
    create(:provident_fund, participation_date: Time.zone.now.beginning_of_day, member_retirement_fund_number: 'number_1', is_an_american: true,
    has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: BigDecimal.new('50'), a_fund_percentage: '40', b_fund_percentage: '30', profile_id: @test_profile.id)


    @test_user.add_role(@admin_role)
    get "/profiles/#{@test_profile.id}/provident_fund"
    assert_response :ok
    assert_equal json_res['data']['member_retirement_fund_number'], 'number_1'
  end

  test 'post create and patch update' do
    params = {
        provident_fund: {
             participation_date: Time.zone.now.beginning_of_day,
             member_retirement_fund_number: 'number_1', is_an_american: true,
             has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: '50', a_fund_percentage: '40', b_fund_percentage: '30'
         },
        first_beneficiary: {
            name: 'test',
            address: 'tesrt'
        },
        second_beneficiary: {
            address: 'test2'
        }
    }
    ProvidentFundsController.any_instance.stubs(:current_user).returns(@another_user)
    post "/profiles/#{@test_profile.id}/provident_fund", params: params, as: :json
    assert_response 403
    ProvidentFundsController.any_instance.stubs(:current_user).returns(@test_user)
    post "/profiles/#{@test_profile.id}/provident_fund", params: params, as: :json
    assert_response :ok
    assert_equal json_res['data'], ProvidentFund.first.id
    params = {
        provident_fund: {

            member_retirement_fund_number: 'number_1', is_an_american: false,
            has_permanent_resident_certificate: false, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: '60', a_fund_percentage: '50', b_fund_percentage: '30'
        },
        first_beneficiary: {
            name: 'test2'
        },
        third_beneficiary: {
            address: 'test2'
        }
    }
    patch "/profiles/#{@test_profile.id}/provident_fund", params: params, as: :json
    assert_response :ok
    assert_equal @test_profile.provident_fund.steady_fund_percentage, BigDecimal.new('60')
    assert_equal ProvidentFund.first.is_an_american, false
    assert_equal ProvidentFund.first.first_beneficiary.name, 'test2'
    assert_equal ProvidentFund.first.first_beneficiary.address, 'tesrt'
    assert_equal ProvidentFund.first.third_beneficiary.address, 'test2'

    get "/provident_funds", as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['third_beneficiary']['address'], 'test2'


    @test_profile2 = create_test_user.profile
    @test_profile3 = create_test_user.profile

    params = {
        provident_fund: {
            member_retirement_fund_number: 'number_1', is_an_american: true,
            has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: '60', a_fund_percentage: '50', b_fund_percentage: '30'
        },
        first_beneficiary: {
            name: 'test2'
        },
        third_beneficiary: {
            address: 'test2'
        }
    }
    patch "/profiles/#{@test_profile2.id}/provident_fund", params: params, as: :json
    assert_response :ok

    patch "/profiles/#{@test_profile3.id}/provident_fund", params: params, as: :json
    assert_response :ok

    get "/provident_funds", as: :json
    assert_response :ok
    assert json_res['data'][0].keys.include?('is_leave')

    params = {
        third_beneficiary: {
            address: 'test3'
        }
    }
    patch "/profiles/#{@test_profile.id}/provident_fund", params: params, as: :json
    assert_response :ok
    assert_equal @test_profile.provident_fund.third_beneficiary.address , 'test3'


    get '/provident_funds.xlsx'
    assert_response :success
  end

  test 'should get index' do
    @test_profile2 = create_test_user.profile
    @test_profile3 = create_test_user.profile
    params = {
        provident_fund: {
          participation_date: Time.zone.now.beginning_of_day,
            member_retirement_fund_number: 'number_2', is_an_american: true,
            has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: '60', a_fund_percentage: '50', b_fund_percentage: '30', provident_fund_resignation_date: '2015/05/06'
        },
        first_beneficiary: {
            name: 'test2'
        },
        third_beneficiary: {
            address: 'test2'
        }
    }
    ProvidentFundsController.any_instance.stubs(:current_user).returns(@another_user)
    post "/profiles/#{@test_profile.id}/provident_fund", params: params, as: :json
    assert_response 403
    ProvidentFundsController.any_instance.stubs(:current_user).returns(@test_user)
    post "/profiles/#{@test_profile.id}/provident_fund", params: params, as: :json
    assert_response :ok
    post "/profiles/#{@test_profile2.id}/provident_fund", params: params, as: :json
    assert_response :ok
    params = {
        provident_fund: {
          participation_date: Time.zone.now.beginning_of_day,
            member_retirement_fund_number: 'number_1', is_an_american: true, provident_fund_resignation_date: Time.zone.now.beginning_of_day,
            has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: '60', a_fund_percentage: '50', b_fund_percentage: '30'
        },
        first_beneficiary: {
            name: 'test2'
        },
        third_beneficiary: {
            address: 'test2'
        }
    }
    post "/profiles/#{@test_profile3.id}/provident_fund", params: params, as: :json
    assert_response :ok
    get '/provident_funds', as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 3
    assert_equal json_res['meta'], {"total_count"=>3, "current_page"=>1, "total_pages"=>1, "sort_column"=>"empoid", "sort_direction"=>"asc"}

    params = {
      participation_date: {
        begin: Time.zone.now.strftime('%Y/%m/%d'),
        end: Time.zone.now.strftime('%Y/%m/%d')
      }
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 3

    params = {
      participation_date: {
        begin: (Time.zone.now + 1.day).strftime('%Y/%m/%d'),
        end: (Time.zone.now + 1.day).strftime('%Y/%m/%d')
      }
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 0


    params = {
      provident_fund_resignation_date: {
        begin: (Time.zone.now).strftime('%Y/%m/%d'),
        end: (Time.zone.now).strftime('%Y/%m/%d')
      }
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 1

    params = {
      provident_fund_resignation_date: {
        begin: (Time.zone.now + 1.day).strftime('%Y/%m/%d'),
        end: (Time.zone.now + 1.day).strftime('%Y/%m/%d')
      }
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 0


    params = {
      date_of_employment: {
        begin: @test_profile.data['position_information']['field_values']['date_of_employment'],
        end: @test_profile.data['position_information']['field_values']['date_of_employment']
      }
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 1

    params = {
      date_of_employment: {
        begin: @test_profile.data['position_information']['field_values']['date_of_employment'] + '1',
        end: @test_profile.data['position_information']['field_values']['date_of_employment'] + '1'
      }
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 0


    params = {
      date_of_birth: {
        begin: @test_profile.data['personal_information']['field_values']['date_of_birth'],
        end: @test_profile.data['personal_information']['field_values']['date_of_birth']
      }
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 1

    params = {
      date_of_birth: {
        begin: @test_profile.data['personal_information']['field_values']['date_of_birth'] + '1',
        end: @test_profile.data['personal_information']['field_values']['date_of_birth'] + '1'
      }
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 0




    params = {
        member_retirement_fund_number: 'number_2'
    }
    get provident_funds_url(params), as: :json

    assert_equal json_res['data'].count, 2

    params = {
        position: @test_profile3.user.position_id
    }
    get provident_funds_url(params), as: :json
    assert_equal json_res['data'].count, 3

    params = {
        national: [@test_profile3.data['personal_information']['field_values']['national']]
    }
    get provident_funds_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count >= 1, true
    assert_equal json_res['data'].select{|record| record['profile']['data']['personal_information']['field_values']['national'] == @test_profile3.data['personal_information']['field_values']['national']}.count, json_res['data'].count

    params = {
        is_leave: [true]
    }
    get provident_funds_url(params), as: :json
    assert_response :ok
    count = json_res['data'].count

    params = {
        is_leave: [false]
    }
    get provident_funds_url(params), as: :json
    assert_response :ok
    assert_equal (3 - count), json_res['data'].count

    params = {
        sort_column: 'empoid',
        sort_direction: 'desc'
    }
    get provident_funds_url(params), as: :json
    assert_response :ok

    params = {
        sort_column: 'date_of_employment',
        sort_direction: 'desc'
    }
    get provident_funds_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['profile']['data']['position_information']['field_values']['date_of_employment'] >=  json_res['data'][-1]['profile']['data']['position_information']['field_values']['date_of_employment'], true


    params = {
      sort_column: 'is_leave',
      sort_direction: 'desc'
    }

    get provident_funds_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['id'], ProvidentFund.left_outer_joins(user: :resignation_records).group('provident_funds.id, resignation_records.id').order('resignation_records.id asc, provident_funds.id').first.id


    get field_options_provident_funds_url
    assert_response :ok
    assert_equal json_res['data'].keys.include?('is_leave'), true

    get '/provident_funds.xlsx'
    assert_response :success
  end
  test "should export xlsx" do
    ProvidentFundsController.any_instance.stubs(:current_user).returns(@another_user)
    get '/provident_funds.xlsx'
    assert_response 403
    ProvidentFundsController.any_instance.stubs(:current_user).returns(@test_user)
    get '/provident_funds.xlsx'
    assert_response :success
  end

  test 'should get create_options' do
    get create_options_provident_funds_url
    assert_response :ok
    assert json_res['data'].keys.include? ('nationality')
    assert json_res['data'].keys.include? ('type_of_id')
  end


  test 'can_create' do
    test_user = create_test_user
    ProfileService.stubs(:date_of_employment).with(any_parameters).returns(Time.zone.now.beginning_of_day)
    get can_create_profile_provident_fund_url(profile_id: test_user.profile.id, join_date: (Time.zone.now + 1.day).strftime('%Y/%m/%d'))
    assert @response.body
    get can_create_profile_provident_fund_url(profile_id: test_user.profile.id, join_date: (Time.zone.now - 1.day).strftime('%Y/%m/%d'))
    assert_equal  @response.body , 'false'
    get can_create_profile_provident_fund_url(profile_id: test_user.profile.id, join_date: nil)
    assert_response 422
  end

end
