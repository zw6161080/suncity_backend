module UserSortAble
  extend ActiveSupport::Concern

  included do
    scope :join_user, lambda {
      joins(:user)
    }

    scope :join_user_and_profile, lambda{
      joins(user: :profile)
    }

    scope :by_empoid, lambda {|empoid|
      where(users: {empoid: empoid}) if empoid
    }

    scope :by_name, lambda{|name|
      where(users:{ select_language => name}) if name
    }

    scope :by_company_name, lambda {|company_name|
      where(users: {company_name: company_name}) if company_name
    }

    scope :by_location_id, lambda {|location_id|
      where(users: {location_id: location_id}) if location_id
    }
    scope :by_position_id, lambda {|position_id|
      where(users: {position_id: position_id}) if position_id
    }
    scope :by_department_id, lambda {|department_id|
      where(users: {department_id: department_id}) if department_id
    }
    scope :by_grade, lambda {|grade|
      where(users: {grade: grade}) if grade
    }

    scope :by_date_of_employment, lambda { |from, to|
      if from && to
        where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
      elsif from
        where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
      elsif to
        where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
      end
    }

    scope :by_position_resigned_date, lambda { |from, to|
      if from && to
        where("profiles.data #>> '{position_information, field_values, position_resigned_date}' >= :from", from: from)
          .where("profiles.data #>> '{position_information, field_values, position_resigned_date}' <= :to", to: to)
      elsif from
        where("profiles.data #>> '{position_information, field_values, position_resigned_date}' >= :from", from: from)
      elsif to
        where("profiles.data #>> '{position_information, field_values, position_resigned_date}' <= :to", to: to)
      end
    }


  end
end
