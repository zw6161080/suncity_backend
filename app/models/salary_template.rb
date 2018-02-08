# == Schema Information
#
# Table name: salary_templates
#
#  id                           :integer          not null, primary key
#  template_chinese_name        :string
#  template_english_name        :string
#  template_simple_chinese_name :string
#  belongs_to                   :jsonb
#  comment                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  new_year_bonus               :decimal(15, 2)
#  project_bonus                :decimal(15, 2)
#  product_bonus                :decimal(15, 2)
#  tea_bonus                    :decimal(15, 2)
#  kill_bonus                   :decimal(15, 2)
#  performance_bonus            :decimal(15, 2)
#  charge_bonus                 :decimal(15, 2)
#  commission_bonus             :decimal(15, 2)
#  receive_bonus                :decimal(15, 2)
#  exchange_rate_bonus          :decimal(15, 2)
#  guest_card_bonus             :decimal(15, 2)
#  respect_bonus                :decimal(15, 2)
#  region_bonus                 :decimal(15, 2)
#  basic_salary                 :decimal(15, 2)
#  bonus                        :decimal(15, 2)
#  attendance_award             :decimal(15, 2)
#  house_bonus                  :decimal(15, 2)
#  service_award                :decimal(15, 2)
#  internship_bonus             :decimal(15, 2)
#  performance_award            :decimal(15, 2)
#  special_tie_bonus            :decimal(15, 2)
#

class SalaryTemplate < ApplicationRecord
  include StatementAble
  validates :template_chinese_name, :template_english_name, presence: true, uniqueness: true
  validates :basic_salary, :bonus, :attendance_award, :house_bonus, :tea_bonus, :kill_bonus, :performance_bonus, :charge_bonus, :commission_bonus, :receive_bonus, :exchange_rate_bonus, :guest_card_bonus, :respect_bonus, :new_year_bonus, :project_bonus, :product_bonus,
            :service_award, :internship_bonus, :performance_award, :special_tie_bonus,
            presence: true

  scope :by_new_year_bonus, lambda { |new_year_bonus|
    where(new_year_bonus: new_year_bonus) if new_year_bonus
  }
  scope :by_project_bonus, lambda { |project_bonus|
    where(project_bonus: project_bonus) if project_bonus
  }
  scope :by_product_bonus, lambda { |product_bonus|
    where(product_bonus: product_bonus) if product_bonus
  }
  scope :by_tea_bonus, lambda { |tea_bonus|
    where(tea_bonus: tea_bonus) if tea_bonus
  }
  scope :by_kill_bonus, lambda { |kill_bonus|
    where(kill_bonus: kill_bonus) if kill_bonus
  }
  scope :by_performance_bonus, lambda { |performance_bonus|
    where(performance_bonus: performance_bonus) if performance_bonus
  }
  scope :by_charge_bonus, lambda { |charge_bonus|
    where(charge_bonus: charge_bonus) if charge_bonus
  }
  scope :by_commission_bonus, lambda { |commission_bonus|
    where(commission_bonus: commission_bonus) if commission_bonus
  }
  scope :by_receive_bonus, lambda { |receive_bonus|
    where(receive_bonus: receive_bonus) if receive_bonus
  }
  scope :by_exchange_rate_bonus, lambda { |exchange_rate_bonus|
    where(exchange_rate_bonus: exchange_rate_bonus) if exchange_rate_bonus
  }
  scope :by_guest_card_bonus, lambda { |guest_card_bonus|
    where(guest_card_bonus: guest_card_bonus) if guest_card_bonus
  }
  scope :by_respect_bonus, lambda { |respect_bonus|
    where(respect_bonus: respect_bonus) if respect_bonus
  }
  scope :by_region_bonus, lambda { |region_bonus|
    where(region_bonus: region_bonus) if region_bonus
  }
  scope :by_commission_bonus, lambda { |commission_bonus|
    where(commission_bonus: commission_bonus) if commission_bonus
  }
  scope :by_basic_salary, lambda { |basic_salary|
    where(basic_salary: basic_salary) if basic_salary
  }
  scope :by_bonus, lambda { |bonus|
    where(bonus: bonus) if bonus
  }
  scope :by_attendance_award, lambda { |attendance_award|
    where(attendance_award: attendance_award) if attendance_award
  }
  scope :by_house_bonus, lambda { |house_bonus|
    where(house_bonus: house_bonus) if house_bonus
  }
  scope :by_template_name, lambda { |template_name|
    if (template_name.is_a? Array) && !template_name.empty?
      template_name_for_sql = template_name.map {|val| "%#{val}%" }
      where("template_#{select_language}  ILIKE ANY ( array[:template_name_for_sql]) ", template_name_for_sql: template_name_for_sql)
    end
  }
  scope :by_total_count, lambda { |total_count|
    where("(basic_salary + bonus + attendance_award + house_bonus + region_bonus + service_award + internship_bonus)  = :total_count", total_count: total_count) if total_count
  }

  scope :by_position_id, lambda { |position_id|
    if (position_id.is_a? Array) && !position_id.empty?
      ids = Department.all.map do |department|
        where("belongs_to -> :department_id ?| array[:position_id]", department_id: department.id.to_s, position_id: position_id).ids
      end
      where(id: ids.flatten.compact)
    end
  }
  scope :by_department_id, lambda { |department_id|
    if (department_id.is_a? Array) && !department_id.empty?
      where("belongs_to ?| array[:department_id]", department_id: department_id)
    end
  }

  scope :order_by, lambda { |sort_column, sort_direction|
    if sort_column.to_sym == :template_name
      order("template_#{select_language}" => sort_direction)
    elsif sort_column.to_sym == :total_count
      order("(basic_salary + bonus + attendance_award + house_bonus + region_bonus + service_award + internship_bonus)  #{sort_direction}")
    else
      order(sort_column => sort_direction)
    end
  }

  def validate_result
    self.valid?
    {
      template_name: self.errors[:template_chinese_name].empty? && self.errors[:template_simple_chinese_name].empty? && self.errors[:template_english_name].empty?,
      belongs_to: self.errors[:belongs_to].empty?,
      comment: self.errors[:annual_leave].empty?,
      new_year_bonus: self.errors[:new_year_bonus].empty?,
      project_bonus: self.errors[:project_bonus].empty?,
      product_bonus: self.errors[:product_bonus].empty?,
      tea_bonus: self.errors[:tea_bonus].empty?,
      kill_bonus: self.errors[:kill_bonus].empty?,
      performance_bonus: self.errors[:performance_bonus].empty?,
      charge_bonus: self.errors[:charge_bonus].empty?,
      commission_bonus: self.errors[:commission_bonus].empty?,
      receive_bonus: self.errors[:receive_bonus].empty?,
      exchange_rate_bonus: self.errors[:exchange_rate_bonus].empty?,
      guest_card_bonus: self.errors[:guest_card_bonus].empty?,
      respect_bonus: self.errors[:respect_bonus].empty?,
      region_bonus: self.errors[:region_bonus].empty?,
      basic_salary: self.errors[:basic_salary].empty?,
      bonus: self.errors[:bonus].empty?,
      attendance_award: self.errors[:attendance_award].empty?,
      house_bonus: self.errors[:house_bonus].empty?,
      service_award: self.errors[:service_award].empty?,
      internship_bonus: self.errors[:internship_bonus].empty?,
      performance_award: self.errors[:performance_award].empty?,
      special_tie_bonus: self.errors[:special_tie_bonus].empty?,
    }
  end

  def validate_belongs_to
    tag = true
    message = "wrong_department_id_and_position_id: "
    self.belongs_to&.each { |k, v_array|
      department = Department.find(k)
      v_array.each { |v|
        unless department.positions.include? Position.find(v)
          tag = false
          message << "department_id: #{k}, position_id: #{v}"
        end
      }
    }
    {
      tag: tag,
      message: message
    }
  end

  def create_params
    super - :belongs_to
  end

  def belongs_to_string
    string_value = ""
    self.belongs_to&.each { |k, v_array|
      department = Department.find(k)
      v_array.each { |v|
        position = Position.find(v)
        string_value << "#{department.chinese_name}/#{position.chinese_name},"
      }
    }
    string_value.sub(/\,$/, '')
  end

end
