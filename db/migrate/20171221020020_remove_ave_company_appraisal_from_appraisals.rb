class RemoveAveCompanyAppraisalFromAppraisals < ActiveRecord::Migration[5.0]
  def change
    remove_column :appraisals, :ave_company_appraisal, :decimal, precision: 5, scale: 2
  end
end
