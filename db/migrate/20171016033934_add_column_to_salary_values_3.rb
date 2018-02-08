class AddColumnToSalaryValues3 < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_values, :resignation_record_id, :integer
  end
end
