class ChangeCertificateLanguateColumnToDimissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :dimissions, :resignation_certificate_language, :string
    add_column :dimissions, :resignation_certificate_languages, :jsonb
  end
end
