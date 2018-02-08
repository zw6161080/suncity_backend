class CreateAppraisals < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisals do |t|
      t.string   :appraisal_status
      t.string   :appraisal_name
      t.datetime :date_begin
      t.datetime :date_end
      t.integer  :participator_amount

      t.decimal  :ave_total_appraisal, precision: 5, scale: 2
      t.decimal  :ave_superior_appraisal, precision: 5, scale: 2
      t.decimal  :ave_colleague_appraisal, precision: 5, scale: 2
      t.decimal  :ave_subordinate_appraisal, precision: 5, scale: 2
      t.decimal  :ave_self_appraisal, precision: 5, scale: 2

      t.string   :appraisal_introduction

      t.timestamps
    end
  end
end
