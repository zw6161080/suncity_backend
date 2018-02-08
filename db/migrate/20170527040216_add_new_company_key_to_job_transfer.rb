class AddNewCompanyKeyToJobTransfer < ActiveRecord::Migration[5.0]
  def change
    add_column :job_transfers, :new_company_key, :string
    add_column :job_transfers, :original_company_key, :string
    add_column :job_transfers, :new_working_category_key, :string
    add_column :job_transfers, :original_working_category_key, :string
    add_column :job_transfers, :salary_template_type, :string
  end
end
