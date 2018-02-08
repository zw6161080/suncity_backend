# == Schema Information
#
# Table name: provident_funds
#
#  id                                 :integer          not null, primary key
#  member_retirement_fund_number      :string
#  tax_registration                   :string
#  icbc_account_number_mop            :string
#  icbc_account_number_rmb            :string
#  is_an_american                     :boolean
#  has_permanent_resident_certificate :boolean
#  supplier                           :string
#  steady_growth_fund_percentage      :decimal(15, 2)
#  steady_fund_percentage             :decimal(15, 2)
#  a_fund_percentage                  :decimal(15, 2)
#  b_fund_percentage                  :decimal(15, 2)
#  profile_id                         :integer
#  first_beneficiary_id               :integer
#  second_beneficiary_id              :integer
#  third_beneficiary_id               :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  provident_fund_resignation_reason  :string
#  user_id                            :integer
#  participation_date                 :datetime
#  provident_fund_resignation_date    :datetime
#
# Indexes
#
#  index_provident_funds_on_first_beneficiary_id   (first_beneficiary_id)
#  index_provident_funds_on_profile_id             (profile_id)
#  index_provident_funds_on_second_beneficiary_id  (second_beneficiary_id)
#  index_provident_funds_on_third_beneficiary_id   (third_beneficiary_id)
#  index_provident_funds_on_user_id                (user_id)
#

class ProvidentFund < ApplicationRecord
  # include GetSelectAble
  include StatementAble
  belongs_to :user
  belongs_to :profile
  belongs_to :first_beneficiary, :class_name => 'Beneficiary', :foreign_key => "first_beneficiary_id"
  belongs_to :second_beneficiary, :class_name=> 'Beneficiary', :foreign_key => "second_beneficiary_id"
  belongs_to :third_beneficiary, :class_name => 'Beneficiary', :foreign_key => "third_beneficiary_id"
  validates   :member_retirement_fund_number, :participation_date, presence: true
  after_save :deal_with_reports
  after_create :generate_employee_fund_switching_report_item
  before_destroy :delete_employee_fund_switching_report_item



  def is_leave
    self.user.resignation_records.where(status: :being_valid).count > 0
  end
  def delete_employee_fund_switching_report_item
    EmployeeFundSwitchingReportItem.delete(self.user)   if self.user
  end
  def generate_employee_fund_switching_report_item
    EmployeeFundSwitchingReportItem.generate(self.user) if self.user
  end

  def deal_with_reports
    if self.provident_fund_resignation_date
      EmployeeRedemptionReportItem.generate(self.user)  if EmployeeRedemptionReportItem.where(user_id: self.user.id).empty?
      DepartureEmployeeTaxpayerNumberingReportItem.generate(self.user, self.provident_fund_resignation_date) if DepartureEmployeeTaxpayerNumberingReportItem.where(user_id: self.user.id).empty?
    else
      EmployeeRedemptionReportItem.where(user_id: self.user_id).destroy_all
      DepartureEmployeeTaxpayerNumberingReportItem.where(user_id: self.user_id).destroy_all
    end
  end


  def self.field_options
    query = self.left_outer_joins(:first_beneficiary, :second_beneficiary, :third_beneficiary, :profile, user: [:position, :department])
    grade = Config.get_option_from_selects('grade', query.select('users.grade').map{|item| item['grade']}.try(:uniq))
    gender = Config.get_option_from_selects('gender', query.select("profiles.data -> 'personal_information' -> 'field_values' -> 'gender' as gender").map{|item| item['gender']}.try(:uniq))
    national = Config.get_option_from_selects('nationality',query.select("profiles.data -> 'personal_information' -> 'field_values' -> 'national' as national").map{|item| item['national']}.try(:uniq))
    type_of_id = Config.get_option_from_selects('type_of_id',query.select("profiles.data -> 'personal_information' -> 'field_values' -> 'type_of_id' as type_of_id").map{|item| item['type_of_id']}.try(:uniq))
    certificate_issued_country = Config.get_option_from_selects('nationality',query.select("profiles.data -> 'personal_information' -> 'field_values' -> 'certificate_issued_country' as certificate_issued_country").map{|item| item['certificate_issued_country']}.try(:uniq))

    tax_registration = Config.get_option_from_selects('nationality', query.select(:tax_registration).map{|item| item['tax_registration']}.try(:uniq).compact)

    is_an_american = Config.get_option_from_selects('provident_fund', query.select(:is_an_american).map{|item| item['is_an_american']}.try(:uniq))

    has_permanent_resident_certificate = Config.get_option_from_selects('provident_fund',query.select(:has_permanent_resident_certificate).map{|item| item['has_permanent_resident_certificate']}.try(:uniq))
    #Todo:供应商还未提供
    supplier = [{
        key: 'to_do',
        chinese_name: '待提供',
        englihs_name: 'to_do',
        simple_chinese_name: '待提供'
                }]
    provident_fund_resignation_reason = [
      {
        key: 'normal_retirement',
        chinese_name: '正常退休',
        englihs_name: 'Normal retirement',
        simple_chinese_name: '正常退休'
      },
      {
        key: 'early_retirement',
        chinese_name: '提早退休',
        englihs_name: 'Early retirement',
        simple_chinese_name: '提早退休'
      },
      {
        key: 'die',
        chinese_name: '身故',
        englihs_name: 'Die',
        simple_chinese_name: '身故'
      },
      {
        key: 'resign',
        chinese_name: '辭職',
        englihs_name: 'Resign',
        simple_chinese_name: '辞职'
      },
      {
        key: 'to_be_terminated_or_demobilized',
        chinese_name: '遭解約或遣散',
        englihs_name: 'To be terminated or demobilized',
        simple_chinese_name: '遭解约或遣散'
      },
      {
        key: 'company_dissolution',
        chinese_name: '公司解散',
        englihs_name: 'Company dissolution',
        simple_chinese_name: '公司解散'
      },
      {
        key: 'fire',
        chinese_name: '解僱',
        englihs_name: 'Fire',
        simple_chinese_name: '解雇'
      },
      {
        key: 'long_term_incapacity',
        chinese_name: '長期無工作能力',
        englihs_name: 'Long term incapacity',
        simple_chinese_name: '长期无工作能力'
      },
    ]
    departments= query.select('departments.*').distinct.as_json

    positions = query.select('positions.*').distinct.as_json
    is_leave = [{
                  key: true,
                  chinese_name: '已離職',
                  english_name: 'left',
                  simple_chinese_name: '已离职'
                },
                {
                  key: false,
                  chinese_name: '在職',
                  english_name: 'on_work',
                  simple_chinese_name: '在职',
                }]

    {
        grade: grade,
        gender: gender,
        national: national,
        type_of_id: type_of_id,
        certificate_issued_country: certificate_issued_country,
        tax_registration: tax_registration,
        is_an_american: is_an_american,
        has_permanent_resident_certificate: has_permanent_resident_certificate,
        provident_fund_resignation_reason: provident_fund_resignation_reason,
        supplier: supplier,
        is_leave: is_leave,
        position: positions,
        department: departments,
    }
  end


  scope :by_user, lambda { |user|
    where(user: user) if user
  }
  scope :update_profile, lambda { |profile_id|
    update(profile_id: profile_id)
  }
  scope :update_first_beneficiary, lambda { |first_beneficiary_id|
    update(first_beneficiary_id: first_beneficiary_id)
  }
  scope :update_second_beneficiary, lambda { |second_beneficiary_id|
    update(second_beneficiary_id: second_beneficiary_id)
  }
  scope :update_third_beneficiary, lambda { |third_beneficiary_id|
    update(third_beneficiary_id: third_beneficiary_id)
  }

  scope :by_created_at, lambda { |from, to|
    if from && to
    where("created_at > :from", from: Time.zone.parse(from))
        .where("created_at < :to", to: Time.zone.parse(to))
    elsif from
      where("created_at > :from", from: Time.zone.parse(from))
    else
      where("created_at < :to", to: Time.zone.parse(to))
    end
  }

  scope :by_member_retirement_fund_number, lambda {| member_retirement_fund_number |
    where(member_retirement_fund_number: member_retirement_fund_number)
  }
  scope :by_tax_registration, lambda {| tax_registration |
    where(tax_registration: tax_registration)
  }
  scope :by_icbc_account_number_mop, lambda {| icbc_account_number_mop|
    where(icbc_account_number_mop: icbc_account_number_mop)
  }
  scope :by_icbc_account_number_rmb, lambda {| icbc_account_number_rmb|
    where(icbc_account_number_rmb: icbc_account_number_rmb)
  }
  scope :by_is_an_american, lambda {| is_an_american|
    where(is_an_american: is_an_american)
  }
  scope :by_has_permanent_resident_certificate, lambda {| has_permanent_resident_certificate|
    where(has_permanent_resident_certificate: has_permanent_resident_certificate)
  }
  scope :by_supplier, lambda {| supplier|
    where(supplier: supplier)
  }
  scope :by_steady_growth_fund_percentage, lambda {| has_steady_growth_fund_percentage|
    where(steady_growth_fund_percentage: has_steady_growth_fund_percentage)
  }
  scope :by_steady_fund_percentage, lambda {| steady_fund_percentage|
    where(steady_fund_percentage: steady_fund_percentage)
  }
  scope :by_a_fund_percentage, lambda {| a_fund_percentage|
    where(a_fund_percentage: a_fund_percentage)
  }
  scope :by_b_fund_percentage, lambda {| b_fund_percentage|
    where(b_fund_percentage: b_fund_percentage)
  }
  scope :by_participation_date, lambda {| from, to|
    if from && to
      where("participation_date>= :from", from: Time.zone.parse(from))
          .where("participation_date<= :to", to: Time.zone.parse(to))
    elsif from
      where("participation_date >= :from", from: Time.zone.parse(from))
    elsif to
      where("participation_date <= :to", to: Time.zone.parse(to))
    end
  }
  scope :by_provident_fund_resignation_date, lambda {| from, to|
    if from && to
      where("provident_fund_resignation_date >= :from", from: Time.zone.parse(from))
          .where("provident_fund_resignation_date <= :to", to: Time.zone.parse(to))
    elsif from
      where("provident_fund_resignation_date >= :from", from: Time.zone.parse(from))
    elsif to
      where("provident_fund_resignation_date <= :to", to: Time.zone.parse(to))
    end
  }
  scope :by_provident_fund_resignation_reason, lambda {| provident_fund_resignation_reason|
    where(provident_fund_resignation_reason: provident_fund_resignation_reason)
  }

  scope :by_position, lambda { |position_id|
    includes(:user).where(users: {position_id: position_id})
  }

  scope :by_department, lambda { |department_id|
    includes(:user).where(users: {department_id: department_id})
  }

  scope :by_chinese_name, lambda { |chinese_name|
    where('users.chinese_name like ?', "%#{chinese_name}%") if chinese_name
  }

  scope :by_english_name, lambda { |english_name|
    where('users.english_name like ?', "%#{english_name}%") if english_name
  }

  scope :by_empoid, lambda { |empoid|
    includes(:user).where(users: {empoid: empoid}) if empoid
  }

  scope :by_grade, lambda { |grade|
    includes(:user).where(users: {grade: grade}) if grade
  }

  scope :by_date_of_employment, lambda { |from, to|
    if from && to
      includes(:profile)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from ", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes(:profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes(:profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :by_date_of_birth, lambda { |from, to|
    if from && to
      includes(:profile)
          .where("profiles.data #>> '{personal_information,field_values, date_of_birth}' >= :from ", from: from)
          .where("profiles.data #>> '{personal_information,field_values, date_of_birth}' <= :to", to: to)
    elsif from
      includes(:profile).where("profiles.data #>> '{personal_information,field_values, date_of_birth}' >= :from ", from: from)
    elsif to
      includes(:profile).where("profiles.data #>> '{personal_information,field_values, date_of_birth}' <= :to", to: to)
    end
  }

  scope :by_gender, lambda { |gender|
    if gender && (gender.is_a? Array )
      includes(:profile).where("profiles.data -> 'personal_information' -> 'field_values' -> 'gender' ?| array["+ gender.map{|item| "'#{item}'"}.join(',') +"]" )
    end
  }

  scope :by_national, lambda { |national|
    if national && (national.is_a? Array )
      includes(:profile).where("profiles.data -> 'personal_information' -> 'field_values' -> 'national' ?| array["+ national.map{|item| "'#{item}'"}.join(',') +"]" )
    end
  }

  scope :by_place_of_birth, lambda {|place_of_birth|
    if place_of_birth
      includes(:profile).where("profiles.data #>> '{personal_information,field_values, place_of_birth}' = :place_of_birth", place_of_birth: place_of_birth)
    end
  }

  scope :by_email, lambda { |email|
    if email
      includes(:profile).where("profiles.data #>> '{personal_information,field_values, email}' = :email", email: email)
    end
  }

  scope :by_mobile_number, lambda { |mobile_number|
    if mobile_number
      includes(:profile).where("profiles.data #>> '{personal_information,field_values, mobile_number}' = :mobile_number", mobile_number: mobile_number)
    end
  }

  scope :by_address, lambda { |address|
    if address
      includes(:profile).where("profiles.data #>> '{personal_information,field_values, address}' = :address", address: address)
    end
  }

  scope :by_type_of_id, lambda { |type_of_id|
    if type_of_id && (type_of_id.is_a?Array)
    includes(:profile).where("profiles.data -> 'personal_information' -> 'field_values' -> 'type_of_id' ?| array["+ type_of_id.map{|item| "'#{item}'"}.join(',') +"]" )
    end
  }

  scope :by_certificate_issued_country, lambda { |certificate_issued_country|
    if certificate_issued_country && certificate_issued_country.is_a?(Array)
      includes(:profile).where("profiles.data -> 'personal_information' -> 'field_values' -> 'certificate_issued_country' ?| array["+ certificate_issued_country.map{|item| "'#{item}'"}.join(',') +"]" )
    end
  }

  scope :by_id_number, lambda { |id_number|
    if id_number
      includes(:profile).where("profiles.data #>> '{personal_information,field_values, id_number}' = :id_number", id_number: id_number)
    end
  }

  scope :by_tax_number, lambda { |tax_number|
    if tax_number
      includes(:profile).where("profiles.data #>> '{personal_information, field_values, tax_number}' = :tax_number", tax_number: tax_number)
    end
  }

  scope :by_is_leave, lambda { |is_leave|
    unless (is_leave.is_a? Array ) &&  is_leave.count >=2
      if is_leave.first == 'true'
        where(users: {id: ResignationRecord.all.pluck(:user_id)})
      elsif is_leave.first == 'false'
        where.not(users: {id: ResignationRecord.all.pluck(:user_id)})
      end
    end
  }

  scope :order_by, lambda { |sort_column, sort_direction|
    if sort_column == :empoid
      order("users.empoid #{sort_direction}")
    elsif sort_column == :chinese_name
      order("users.chinese_name #{sort_direction}")
    elsif  sort_column == :english_name
      order("users.english_name #{sort_direction}")
    elsif sort_column == :position
      order("users.position_id #{sort_direction}")
    elsif sort_column == :department
      order("users.department_id #{sort_direction}")
    elsif sort_column == :grade
      order("users.grade #{sort_direction}")
    elsif sort_column == :provident_fund_resignation_reason
      order("provident_fund_resignation_reason #{sort_direction}")
    elsif sort_column == :date_of_employment
      if sort_direction == :desc
        order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
      else
        order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
      end
    elsif sort_column == :date_of_birth
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, date_of_birth}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, date_of_birth}' ")
      end
    elsif sort_column == :gender
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, gender}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, gender}' ")
      end
    elsif sort_column == :national
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, national}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, national}' ")
      end
    elsif sort_column == :place_of_birth
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, place_of_birth}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, place_of_birth}' ")
      end
    elsif sort_column == :mobile_number
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, mobile_number}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, mobile_number}' ")
      end
    elsif sort_column == :email
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, email}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, email}' ")
      end
    elsif sort_column == :address
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, address}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, address}' ")
      end
    elsif sort_column == :type_of_id
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, type_of_id}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, type_of_id}' ")
      end
    elsif sort_column == :certificate_issued_country
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, certificate_issued_country}' " )
      else
        order("profiles.data #>> '{personal_information, field_values, certificate_issued_country}' " )
      end
    elsif sort_column == :id_number
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, id_number}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, id_number}' ")
      end
    elsif sort_column == :tax_number
      if sort_direction == :desc
        order("profiles.data #>> '{personal_information, field_values, tax_number}' DESC")
      else
        order("profiles.data #>> '{personal_information, field_values, tax_number}' ")
      end
    elsif sort_column == :is_leave
      if sort_direction == :desc
        left_outer_joins(user: :resignation_records).group('provident_funds.id, resignation_records.id').order('resignation_records.id asc, provident_funds.id')
      else
        left_outer_joins(user: :resignation_records).group('provident_funds.id, resignation_records.id').order('resignation_records.id desc, provident_funds.id')
      end
    else
      order(sort_column => sort_direction)
    end
  }
end
