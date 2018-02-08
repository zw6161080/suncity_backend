class AddColumnToPaySlip < ActiveRecord::Migration[5.0]
  def change
    add_column :pay_slips, :salary_type, :string
    add_column :pay_slips, :resignation_record_id, :integer
  end
end
