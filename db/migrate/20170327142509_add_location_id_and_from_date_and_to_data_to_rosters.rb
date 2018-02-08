class AddLocationIdAndFromDateAndToDataToRosters < ActiveRecord::Migration[5.0]
  def change
    add_reference :rosters, :location, index: true
    add_column :rosters, :from, :date, index: true
    add_column :rosters, :to, :date, index: true
    remove_column :rosters, :year
    remove_column :rosters, :month
  end
end
