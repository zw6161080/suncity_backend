class AddColumnsToResignationRecord < ActiveRecord::Migration[5.0]
  def change
    #valid_date :生效日期
    add_column :resignation_records, :valid_date, :datetime
    #invalid_date: 失效日期
    add_column :resignation_records, :invalid_date, :datetime
    #order_key :排序字段
    add_column :resignation_records, :order_key, :string
  end
end
