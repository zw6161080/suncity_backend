class CreateApprovalItems < ActiveRecord::Migration[5.0]
  def change
    create_table :approval_items do |t|
      t.references :user, foreign_key: true
      t.datetime :datetime
      t.text :comment
      t.references :approvable, polymorphic: true

      t.timestamps
    end
  end
end
