class ChangeResultDefaultInInterviews < ActiveRecord::Migration[5.0]
  def change
    change_column_default :interviews, :result, 4
  end
end
