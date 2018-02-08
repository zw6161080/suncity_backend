class ChangeDecimalPrecisionForCompensationFromDimissionFollowUp < ActiveRecord::Migration[5.0]
  def change
    remove_column :dimission_follow_ups, :compensation, :decimal
    add_column :dimission_follow_ups, :compensation, :decimal, precision:10, scale:2
  end
end
