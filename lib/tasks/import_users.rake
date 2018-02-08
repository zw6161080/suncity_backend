namespace :import_users do
  # bundle exec rake import_users:from_xlsx
  # 第一行是表头显示给客户
  # 第二行是对应的字段用于程序
  desc "Import users."

  task :from_xlsx => :environment do
    xlsx = Roo::Excelx.new("#{Rails.root}/lib/tasks/profiles.xlsx")
    ret = 0
    ActiveRecord::Base.transaction do
      3.upto(xlsx.last_row) do |i|
        ret += 1 if add_profile(xlsx.row(2), xlsx.row(i))
      end
    end
    puts "#{ret} profiles created!"
  end

  def add_profile(header, row)
    data = header.zip(row).to_h
    sections_hash = [
                  {
                       "key" => "personal_information",
                       "field_values" => {
                           "photo" => nil,
                           "gender" => "female",
                           "address" => data['address'].to_s,
                           "national" => data['national'].to_s,
                           "id_number" => data['id_number'].to_s,
                           "type_of_id" => data['type_of_id'].to_s,
                           "chinese_name" => data["chinese_name"].to_s,
                           "english_name" => data["english_name"].to_s,
                           "date_of_birth" => data['date_of_birth'].to_s,
                           "mobile_number" => data['mobile_number'].to_s,
                           "marital_status" => data['marital_status'].to_s,
                           "place_of_birth" => data['place_of_birth'].to_s,
                           "date_of_expiry" => data['date_of_expiry'].to_s
                       }
                   },
                   {
                       "key" => "position_information",
                       "field_values" =>
                           {
                               "empoid" => data['empoid'].to_s,
                               "company_name" => data['company_name'].to_s,
                               "location" => data['location'].to_s,
                               "department" => data['department'].to_i,
                               "position" => data['position'].to_i,
                               "grade" => data['grade'].to_s,
                               "department_in_english" => data['department_in_english'].to_s,
                               "position_in_english" => data['position_in_english'].to_s,
                               "superior_email" => data['superior_email'].to_s,
                               "division_of_job" => data['division_of_job'].to_s,
                               "employment_status" => data['employment_status'].to_s,
                               "date_of_employment" => data['date_of_employment'].to_s,
                               "seniority_calculation_date" => data['seniority_calculation_date'].to_s,
                               "resigned_date" => data['resigned_date'].to_s,
                               "payment_method" => data['payment_method'].to_s,
                               "provident_fund" => data['provident_fund'].to_s,
                               "insurance" => data['insurance'].to_s,
                               "suncity_charity_fund_status" => data['suncity_charity_fund_status'].to_s,
                               "suncity_charity_join_date" => data['suncity_charity_join_date'].to_s,
                               "cancel_suncity_charity_fund_date" => data['cancel_suncity_charity_fund_date'].to_s,
                               "referrals" => data['referrals'].to_s,
                               "referrals_employee_id" => data['referrals_employee_id'].to_s,
                               "referrals_relationship" => data['referrals_relationship'].to_s,
                               "flight_ticket_benefit" => data['flight_ticket_benefit'].to_s,
                               "housing_benefit" => data['housing_benefit'].to_s,
                               "remark" => data['remark'].to_s
                           }
                   },
  ]

  ret = nil
  ActiveRecord::Base.transaction do
    user = User.new
    user.password = '123456'
    user.save!

    the_profile = user.build_profile
    the_profile.sections = Profile.fork_template(region: 'macau', params: sections_hash)
    the_profile.is_stashed = false
    the_profile.save!

    ret = user
  end
  ret

  end

end