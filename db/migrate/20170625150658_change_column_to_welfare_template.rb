class ChangeColumnToWelfareTemplate < ActiveRecord::Migration[5.0]
  def change
    #force_holiday_make_up强制性假期补偿
    add_column  :welfare_templates, :force_holiday_make_up, :integer
  end
end
