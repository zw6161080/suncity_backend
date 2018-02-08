class AddModelAssociationFieldToReportColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :report_columns, :user_source_model_association_attribute, :string
    add_column :report_columns, :option_attribute, :string
    add_column :reports, :key, :string
  end
end
