class AddSalaryTemplateTypeToTransferLocationItem < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_location_items, :salary_template_type, :string
    remove_column :transfer_location_items, :salary_template_id, :integer
  end
end
