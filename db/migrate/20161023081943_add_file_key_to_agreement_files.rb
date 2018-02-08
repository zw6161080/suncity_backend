class AddFileKeyToAgreementFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :agreement_files, :file_key, :string
  end
end
