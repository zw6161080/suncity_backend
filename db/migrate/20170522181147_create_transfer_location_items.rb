class CreateTransferLocationItems < ActiveRecord::Migration[5.0]
  def change
    create_table :transfer_location_items do |t|

      t.string :region
      t.integer :user_id
      t.integer :transfer_location_apply_id
      t.date :transfer_date
      t.integer :transfer_location_id
      t.integer :salary_template_id
      t.text :comment

      t.timestamps
    end
  end
end
