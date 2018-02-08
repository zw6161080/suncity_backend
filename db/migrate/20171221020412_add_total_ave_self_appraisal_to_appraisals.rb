class AddTotalAveSelfAppraisalToAppraisals < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisals, :total_ave_self_appraisal, :decimal, precision: 5, scale: 2
  end
end
