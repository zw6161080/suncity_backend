class AddNeedNumberToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :need_number, :Integer
  end
end
