class RemoveValidDateToLoveFunds < ActiveRecord::Migration[5.0]
  def change
    remove_column :love_funds, :valid_date, :datetime
  end
end
