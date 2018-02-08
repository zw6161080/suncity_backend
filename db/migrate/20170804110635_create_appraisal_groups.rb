class CreateAppraisalGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_groups do |t|

      t.references :appraisal_department_setting, index: true
      t.string :name

      t.timestamps
    end
  end
end
