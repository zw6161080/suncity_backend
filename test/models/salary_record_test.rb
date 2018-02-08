require "test_helper"

class SalaryRecordTest < ActiveSupport::TestCase
  test 'by_current_valid_record' do
    test_user = create_test_user
    params = {
      salary_begin: (Time.zone.now - 2.day).beginning_of_day,
      salary_end: (Time.zone.now - 1.day).end_of_day,
      change_reason: 'entry',
      basic_salary: '10',
      bonus: '10',
      attendance_award: '10',
      house_bonus: '10',
      new_year_bonus: '10',
      project_bonus: '10',
      product_bonus: '10',
      tea_bonus: '10',
      kill_bonus: '10',
      performance_bonus: '10',
      charge_bonus: '10',
      commission_bonus: '10',
      receive_bonus: '10',
      exchange_rate_bonus: '10',
      guest_card_bonus: '10',
      respect_bonus: '10',
      region_bonus: '10',
      user_id: test_user.id,
    }
    salary_record = SalaryRecord.create(params)

    params = {
      salary_begin: (Time.zone.now - 1.day).beginning_of_day,
      salary_end: (Time.zone.now).end_of_day,
      change_reason: 'entry',
      basic_salary: '10',
      bonus: '10',
      attendance_award: '10',
      house_bonus: '10',
      new_year_bonus: '10',
      project_bonus: '10',
      product_bonus: '10',
      tea_bonus: '10',
      kill_bonus: '10',
      performance_bonus: '10',
      charge_bonus: '10',
      commission_bonus: '10',
      receive_bonus: '10',
      exchange_rate_bonus: '10',
      guest_card_bonus: '10',
      respect_bonus: '10',
      region_bonus: '10',
      user_id: test_user.id,
    }
    salary_record = SalaryRecord.create(params)
    assert test_user.salary_records.by_current_valid_record.count  == 1
  end

  test 'create salary_record' do
    params = {
      salary_begin: Time.zone.now,
      change_reason: 'entry',
      basic_salary: '10',
      bonus: '10',
      attendance_award: '10',
      house_bonus: '10',
      new_year_bonus: '10',
      project_bonus: '10',
      product_bonus: '10',
      tea_bonus: '10',
      kill_bonus: '10',
      performance_bonus: '10',
      charge_bonus: '10',
      commission_bonus: '10',
      receive_bonus: '10',
      exchange_rate_bonus: '10',
      guest_card_bonus: '10',
      respect_bonus: '10',
      region_bonus: '10',
      user_id: test_id = create_test_user.id,
    }
    @salary_record = SalaryRecord.create(params)
    assert test_valid
    assert_equal SalaryRecord.find(@salary_record.id).salary_begin.to_date.to_s, Time.zone.now.to_date.to_s
    assert_equal SalaryRecord.find(@salary_record.id).status, 'being_valid'
    assert SalaryRecord.find(@salary_record.id).order_key =~ /^2/
    params = {
      change_reason: 'entry',
      salary_begin: '2017/06/03',
      basic_salary: '10',
      bonus: '10',
      attendance_award: '10',
      house_bonus: '10',
      new_year_bonus: '10',
      project_bonus: '10',
      product_bonus: '10',
      tea_bonus: '10',
      kill_bonus: '10',
      performance_bonus: '10',
      charge_bonus: '10',
      commission_bonus: '10',
      receive_bonus: '10',
      exchange_rate_bonus: '10',
      guest_card_bonus: '10',
      region_bonus: '10',
      respect_bonus: '10',
      user_id: test_id
    }
    wf2 = SalaryRecord.create(params)
    assert_equal SalaryRecord.where(user_id: test_id).count, 2
    assert_equal SalaryRecord.find(@salary_record.id).status, 'invalid'
    assert SalaryRecord.find(@salary_record.id).order_key =~ /^1/
    assert_equal SalaryRecord.find(wf2.id).status, 'being_valid'
    assert SalaryRecord.find(wf2.id).order_key =~ /^2/
    params = {
      change_reason: 'entry',
      salary_begin: (Time.zone.now + 1.day).strftime('%Y/%m/%d'),
      basic_salary: '10',
      bonus: '10',
      attendance_award: '10',
      house_bonus: '10',
      new_year_bonus: '10',
      project_bonus: '10',
      product_bonus: '10',
      tea_bonus: '10',
      kill_bonus: '10',
      performance_bonus: '10',
      charge_bonus: '10',
      commission_bonus: '10',
      receive_bonus: '10',
      exchange_rate_bonus: '10',
      guest_card_bonus: '10',
      region_bonus: '10',
      respect_bonus: '10',
      user_id: test_id
    }
    wf3 = SalaryRecord.create(params)
    assert_equal SalaryRecord.where(user_id: test_id).count, 3
    assert_equal SalaryRecord.find(@salary_record.id).status, 'invalid'
    assert SalaryRecord.find(@salary_record.id).order_key =~ /^1/
    assert_equal SalaryRecord.find(wf2.id).status, 'being_valid'
    assert SalaryRecord.find(wf2.id).order_key =~ /^2/
    assert_equal SalaryRecord.find(wf3.id).status, 'to_be_valid'
    assert SalaryRecord.find(wf3.id).order_key =~ /^3/
    wf3.update(salary_begin: Time.zone.now)
    assert_equal SalaryRecord.find(wf2.id).status, 'invalid'
    assert SalaryRecord.find(wf2.id).order_key =~ /^1/
    assert_equal SalaryRecord.find(wf3.id).status, 'being_valid'
    assert SalaryRecord.find(wf3.id).order_key =~ /^2/


  end


  def test_delete
    params = {
      salary_begin: Time.zone.now,
      change_reason: 'entry',
      basic_salary: '10',
      bonus: '10',
      attendance_award: '10',
      house_bonus: '10',
      new_year_bonus: '10',
      project_bonus: '10',
      product_bonus: '10',
      tea_bonus: '10',
      kill_bonus: '10',
      performance_bonus: '10',
      charge_bonus: '10',
      commission_bonus: '10',
      receive_bonus: '10',
      exchange_rate_bonus: '10',
      guest_card_bonus: '10',
      respect_bonus: '10',
      region_bonus: '10',
      user_id: test_id = create_test_user.id,
    }
    sr1 = SalaryRecord.create(params)

    params = {
      salary_begin: Time.zone.now + 1.day,
      change_reason: 'entry',
      basic_salary: '10',
      bonus: '10',
      attendance_award: '10',
      house_bonus: '10',
      new_year_bonus: '10',
      project_bonus: '10',
      product_bonus: '10',
      tea_bonus: '10',
      kill_bonus: '10',
      performance_bonus: '10',
      charge_bonus: '10',
      commission_bonus: '10',
      receive_bonus: '10',
      exchange_rate_bonus: '10',
      guest_card_bonus: '10',
      respect_bonus: '10',
      region_bonus: '10',
      user_id: test_id ,
    }
    sr2 = SalaryRecord.create(params)
    assert_equal SalaryRecord.count , 2
    answer = sr2.destroy
    assert answer
    assert_equal SalaryRecord.count , 1
    answer = sr1.destroy
    assert_not answer
    assert_equal SalaryRecord.count , 1
  end


  private
  def salary_record
      @salary_record ||= SalaryRecord.new
  end

  def test_valid
    assert salary_record.valid?
  end
end
