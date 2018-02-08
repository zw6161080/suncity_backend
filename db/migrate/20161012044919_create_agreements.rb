class CreateAgreements < ActiveRecord::Migration[5.0]
  def change
    create_table :agreements do |t|
      t.string :title
      t.belongs_to :attachment

      t.timestamps
    end
  end
end
