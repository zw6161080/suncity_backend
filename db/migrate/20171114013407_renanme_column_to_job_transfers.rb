class RenanmeColumnToJobTransfers < ActiveRecord::Migration[5.0]
  def change
    rename_column :job_transfers, :salary_template_type, :salary_calculation
    remove_column :job_transfers, :salary_template_id, :integer
    remove_column :job_transfers, :transfer_type_id, :integer
    remove_column :job_transfers, :new_company_id, :integer
    remove_column :job_transfers, :original_company_id, :integer
    remove_column :job_transfers, :new_working_category_id, :integer
    remove_column :job_transfers, :original_working_category_id, :integer
    rename_column :job_transfers, :new_company_key, :new_company_name
    rename_column :job_transfers, :original_company_key, :original_company_name
    rename_column :job_transfers, :new_working_category_key, :new_employment_status
    rename_column :job_transfers, :original_working_category_key, :original_employment_status
  end
end
