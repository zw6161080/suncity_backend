class AdddColumnToPunishments < ActiveRecord::Migration[5.0]
  def change
    #记录是否用于每月薪酬计算时的扣除
    add_column :punishments, :salary_deduct_status, :boolean, default: false
  end
end
