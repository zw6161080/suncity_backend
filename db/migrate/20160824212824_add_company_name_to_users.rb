class AddCompanyNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :company_name, :string
    add_index :users, :company_name

    add_column :users, :employment_status, :string
    add_index :users, :employment_status

    add_column :users, :grade, :string
    add_index :users, :grade

  end
end
