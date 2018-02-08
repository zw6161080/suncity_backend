class FixDimissionTypeColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :dimissions, :type, :dimission_type
  end
end
