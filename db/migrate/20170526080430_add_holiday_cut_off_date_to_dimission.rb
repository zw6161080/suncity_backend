class AddHolidayCutOffDateToDimission < ActiveRecord::Migration[5.0]
  def change
    add_column :dimissions, :holiday_cut_off_date, :date
  end
end
