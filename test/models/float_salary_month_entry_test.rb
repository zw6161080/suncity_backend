require 'test_helper'

class FloatSalaryMonthEntryTest < ActiveSupport::TestCase
  setup do
    User.destroy_all
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)

    @user100 = User.find(100)
    @user101 = User.find(101)
    @user102 = User.find(102)

    department = create(:department, chinese_name: '測試部門')
    location = create(:location, chinese_name: '測試場館')
    location.departments << department
    location.save!

    @user100.location = location
    @user100.department = department
    @user100.save!

    @user101.location = location
    @user101.department = department
    @user101.save!

    @user102.location = location
    @user102.department = department
    @user102.save!

    BonusElement.load_predefined
  end

  test "should import bonus element month amount" do
    year_month = Time.zone.parse('2017/09')
    entry = FloatSalaryMonthEntry.create(
      year_month: year_month,
      status: 'not_approved',
      employees_count: User.count # TODO (zhangmeng): 需要判断是否在职
    )

    assert_nothing_raised do
      BonusElementMonthAmount.import_xlsx('test/models/bonus_element_month_amount_import_test', entry.id)
    end
  end


  test "should month entry created with bonus element month values" do
    year_month = Time.zone.parse('2017/09')
    entry =  FloatSalaryMonthEntry.create!(
      year_month: year_month,
      status: :not_approved,
      employees_count: ProfileService.users4(year_month).count
    )
    LocationDepartmentStatus.create_with_params(year_month, entry.id)
    BonusElement.all.each do |elem|
      Location.with_departments.each do |location|
        loc = location.with_indifferent_access
        loc[:departments].each do |dep|
          setting = BonusElementSetting
                      .where(location_id: loc[:id],
                             department_id: dep[:id],
                             bonus_element_id: elem.id)
                      .first

          assert_not_nil setting

          if setting.departmental?
            assert_equal 1, BonusElementMonthShare
                              .where(location_id: loc[:id],
                                     department_id: dep[:id],
                                     float_salary_month_entry_id: entry.id,
                                     bonus_element_id: elem.id).count

            if elem.levels.nil?
              assert_equal 1, BonusElementMonthAmount
                                .where(location_id: loc[:id],
                                       department_id: dep[:id],
                                       float_salary_month_entry_id: entry.id,
                                       bonus_element_id: elem.id).count
            else
              elem.levels.each do |level|
                assert_equal 1, BonusElementMonthAmount
                                  .where(location_id: loc[:id],
                                         department_id: dep[:id],
                                         float_salary_month_entry_id: entry.id,
                                         bonus_element_id: elem.id,
                                         level: level).count
              end
            end
          end
        end  # loc[:departments].each do |dep|
      end  # Location.with_departments.each do |location|
    end  # BonusElement.all.each do |elem|

    BonusElementItem.generate_all(year_month)

    User.all.find_each do |user|
      query = BonusElementItem
               .where(user: user)
               .where(float_salary_month_entry_id: entry.id)
      assert_equal 1, query.count
      assert_equal BonusElement.count, query.first.bonus_element_item_values.count
    end

  end
end
