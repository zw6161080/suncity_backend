class CreatePunishments < ActiveRecord::Migration[5.0]
  def change
    create_table :punishments do |t|
      t.string  :punishment_status, default: :punishing, index: true #处分状态
      t.date    :punishment_date, index: true #处分日期
      t.string  :punishment_category, index: true #过错类别
      t.string  :punishment_content  #过错内容
      t.string  :punishment_result, index: true #处理结果
      t.date    :punishment_result_validity_end_date #效力废止日期
      t.string  :punishment_remarks #备注
      t.string  :punishment_recorder #录入人

      #被处分人
      t.references :user, foreign_key: true, index: true

      #事件说明
      t.datetime :incident_time_from,  null: false
      t.datetime :incident_time_to,    null: false
      t.string   :incident_place,      null: false
      t.string   :incident_discoverer, null: false
      t.string   :incident_discoverer_phone,    null: false
      t.string   :incident_handler,             null: false
      t.string   :incident_handler_phone,       null: false
      t.string   :incident_description,         null: false
      t.boolean  :incident_financial_influence, null: false
      t.float    :incident_money_involved
      t.boolean  :incident_customer_involved
      t.boolean  :incident_employee_involved
      t.boolean  :incident_casino_involved
      t.boolean  :incident_thirdparty_involved
      t.boolean  :incident_suspended
      t.date     :incident_suspended_date

      #员工回应
      t.boolean  :target_response_title
      t.string   :target_response_content
      t.datetime :target_response_datetime_from
      t.datetime :target_response_datetime_to

      #纪律处分
      t.boolean  :reinstated
      t.date     :reinstated_date

      t.timestamps
    end
  end
end
