class ApplicantProfile
  module ApplicantProfileToProfileSectionsMapping
    extend ActiveSupport::Concern

      class ApplicantProfileToProfileSectionsMap
        def initialize(applicant_profile, applicant_position)
          @applicant_profile = applicant_profile
          @applicant_position = applicant_position
        end

        def commit_mapping
          [
            {
              'key' => 'personal_information',
              'field_values' => self.try("#{@applicant_profile.region}_personal_information")
            },
            {
              'key' => 'position_information',
              'field_values' => self.try("#{@applicant_profile.region}_position_information")
            }, 
            {
              'key' => 'holiday_information',
              'field_values' => self.try("holiday_information")
            }
          ]
        end

        def macau_personal_information
          fields = [
            "photo",
            "gender",
            "address",
            "national",
            "id_number",
            "nick_name",
            "type_of_id",
            "home_number",
            "chinese_name",
            "english_name",
            "date_of_birth",
            "mobile_number",
            "marital_status",
            "place_of_birth",
            "other_phone_number"
          ]
          res = @applicant_profile.data.fetch('personal_information', {}).fetch('field_values', {}).select {|k,v| fields.include?(k) }
          res['date_of_expiry'] = ''
          res
        end

        def manila_personal_information
          fields = [
            'photo',
            'last_name',
            'first_name',
            'middle_name',
            'nick_name',
            'husbands_last_name',
            'gender',
            'place_of_birth',
            'date_of_birth',
            'mobile_number',
            'address',
            'id_number',
            'sss_number',
            'tin_number',
            'pag_ibig_number',
            'phihealth_number',
            'passport_number',
            'marital_status'
         ]
         res = @applicant_profile.data.fetch('personal_information', {}).fetch('field_values', {}).select {|k,v| fields.include?(k) }
         res['date_of_expiry'] = ''
         res
        end

        def macau_position_information
          {
            "empoid" => EmpoidService.get,
            "company_name"=>"",
            "location"=>"",
            "department"=> @applicant_position.department.id,
            "position"=> @applicant_position.position.id,
            "grade"=> @applicant_position.position.grade,
            "department_in_english"=> @applicant_position.department.english_name,
            "position_in_english"=> @applicant_position.position.english_name,
            "superior_email"=>"",
            "division_of_job"=>"",
            "employment_status"=>"",
            "date_of_employment"=>"",
            "seniority_calculation_date"=>"",
            "resigned_date"=>"",
            "payment_method"=>"",
            "provident_fund"=>'',
            "insurance"=>'',
            "suncity_charity_fund_status"=>'',
            "suncity_charity_join_date"=>"",
            "cancel_suncity_charity_fund_date"=>"",
            "referrals"=> get_data(:referrals_information, :referrals),
            "referrals_employee_id"=> get_data(:referrals_information, :referrals_employee_id),
            "referrals_relationship"=> get_data(:referrals_information, :referrals_relationship),
            "flight_ticket_benefit"=>'',
            "housing_benefit"=>'',
            "remark"=>""
          }
        end

        def manila_position_information
          {
            "empoid" => EmpoidService.get,
            "company_name"=>"",
            "location"=>"",
            "department"=> @applicant_position.department.id,
            "position"=> @applicant_position.position.id,
            "grade"=> @applicant_position.position.grade,
            "department_in_english"=> @applicant_position.department.english_name,
            "position_in_english"=> @applicant_position.position.english_name,
            "division_of_job"=>"",
            "employment_status"=>"",
            "date_of_employment"=>"",
            "seniority_calculation_date"=>"",
            "resigned_date"=>"",
            "payment_method"=>"",
            "provident_fund"=>'',
            "insurance"=>'',
            "suncity_charity_fund_status"=>'',
            "suncity_charity_join_date"=>"",
            "cancel_suncity_charity_fund_date"=>"",
            "referrals"=> get_data(:referrals_information, :referrals),
            "referrals_employee_id"=> get_data(:referrals_information, :referrals_employee_id),
            "referrals_relationship"=> get_data(:referrals_information, :referrals_relationship),
            "flight_ticket_benefit"=>'',
            "housing_benefit"=>'',
            "remark"=>""
          }
        end

        def holiday_information
          {
            "probation" => "",
            "notice_period" => "",
            "working_hours" => "",
            "13th_month_salary" => ""
          }
        end

        def get_data(section, field)
          @applicant_profile.data.fetch(section.to_s, {}).fetch('field_values', {}).fetch(field.to_s, {})
        end
      end


    module ClassMethods
       
    end

  end
end
