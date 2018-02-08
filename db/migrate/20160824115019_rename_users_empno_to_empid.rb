class RenameUsersEmpnoToEmpid < ActiveRecord::Migration[5.0]
  def self.up
    rename_column :users, :empno, :empoid
  end

  def self.down
    rename_column :users, :empoid, :empno
  end
end
