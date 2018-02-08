class ChangeDefualtValueToSalaryRecords < ActiveRecord::Migration[5.0]
  def change
    change_column_default :salary_records, :basic_salary, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :attendance_award, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :new_year_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :project_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :product_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :tea_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :kill_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :performance_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :charge_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :commission_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :receive_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :exchange_rate_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :guest_card_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :respect_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :region_bonus, from: nil, to: BigDecimal(0)
    change_column_default :salary_records, :house_bonus, from: nil, to: BigDecimal(0)


  end
end
