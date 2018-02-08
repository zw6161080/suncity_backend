class RenameAddDoublePoy < ActiveRecord::Migration[5.0]
  def change
    if column_exists? :annual_award_report_items, :add_double_poy
      rename_column :annual_award_report_items, :add_double_poy, :add_double_pay
    end
  end
end
