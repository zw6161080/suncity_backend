class AddColumnToResignationRecrod < ActiveRecord::Migration[5.0]
  def change
    add_column :resignation_records, :compensation_year, :boolean
    add_column :resignation_records, :notice_period_compensation, :boolean
  end
end
